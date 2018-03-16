require_relative '../spec_helper'

describe 'ValidateMyRoutes transformation rules' do
  include_context 'with test app including validate my routes'

  describe 'Transformation `value_as`' do
    include_context 'with mocked route in test app with path params validation',
                    'value_as(Integer, greater_than(5))'

    let(:path_param) { '10' }
    include_examples 'returns rule description in body', 'greater than <5>'

    context 'with parameter with correct type and transformed value satisfying the rule' do
      let(:path_param) { '10' }
      include_examples 'succeeds validation'
    end

    context 'with parameter with a wrong type (foo)' do
      let(:path_param) { 'foo' }
      include_examples 'fails validation', 404, 'Not Found',
                       'was expected my_param parameter to be of type <Integer>, but was <foo>'
    end

    context 'with parameter with correct type but transformed value failing the rule (2)' do
      let(:path_param) { '2' }
      include_examples 'fails validation', 404, 'Not Found',
                       'was expected my_param parameter to be greater than <5>, but was <2>'
    end
  end

  describe 'Transformation `transform`' do
    describe 'for a single parameter validation' do
      include_context 'with mocked route in test app', <<-CODE
        class Order
          def initialize(order_type)
            @order_type = order_type
          end
        end

        module OrderTypesFactory
          def self.load_order(order_type)
            # load order configurations from config or database
            # in our case it is simplified to return a Hash if order type is valied
            fail 'order type "bar" is unsupported!' if order_type == 'bar'
            Order.new(order_type) if ['buy_a_pet'].include? order_type
          end
        end

        def_single_param_validator :order_validator do
          validate { |order, _| order.is_a? Order }
        end

        to_order = ->(order_type) { OrderTypesFactory.load_order(order_type) }
        param_validation :order_type, transform(to_order, order_validator)

        get '/orders/:order_type' do
          "validation succeeded for rule: \#{transform(to_order, order_validator).description}"
        end
      CODE

      subject { get "/orders/#{order_type}" }
      let(:order_type) { 'buy_a_pet' }
      include_examples 'returns rule description in body', 'Order validator'

      context 'with parameter passing transformation and transformed value satisfying the rule' do
        let(:order_type) { 'buy_a_pet' }
        include_examples 'succeeds validation'
      end

      context 'with parameter failing the transformation proc' do
        let(:order_type) { 'bar' }
        include_examples 'fails validation', 404, 'Not Found',
                         'order type "bar" is unsupported!'
      end

      context 'with parameter passing transformation but failing the rule (foo)' do
        let(:order_type) { 'foo' }
        include_examples 'fails validation', 404, 'Not Found',
                         'parameter order_type was expected to satisfy: Order validator but was <>'
      end
    end

    describe 'for all parameters validation' do
      include_context 'with mocked route in test app', <<-CODE
        def_all_params_validator :search_criteria do |allowed_keys|
          validate { |params| params.keys.all? { |key| allowed_keys.include?(key.to_sym) } }
          description { "only \#{allowed_keys.join(', ')} search criterias allowed" }
        end

        # :q parameter in the query string identifies that it's a search request but it is not a
        # part of search criteria
        orders_search_transform = ->(params) do
          fail 'could not extract orders search criteria' if params['fail'] == 'true'
          params.select { |key| key.to_sym != :q }
        end

        SEARCH_PARAMS = %i(order_type order_date)
        all_params_validation transform(orders_search_transform, search_criteria(SEARCH_PARAMS))

        get '/orders' do
          rule = transform(orders_search_transform, search_criteria(SEARCH_PARAMS))
          "validation succeeded for rule: \#{rule.description}"
        end
      CODE

      subject { get "/orders?#{orders_search}" }
      let(:orders_search) { 'q&order_type=foo' }
      include_examples 'returns rule description in body',
                       'only order_type, order_date search criterias allowed'

      context 'with valid search criteria (`q&order_type=buy_a_pet`)' do
        let(:orders_search) { 'q&order_type=buy_a_pet' }
        include_examples 'succeeds validation'
      end

      context 'with parameters failing transformation' do
        let(:orders_search) { 'fail=true' }
        include_examples 'fails validation', 400, 'Bad Request',
                         'could not extract orders search criteria'
      end

      context 'with parameters passing transformation but failing the rule (`foo`)' do
        let(:orders_search) { 'foo' }
        include_examples 'fails validation', 400, 'Bad Request',
                         'parameters were expected to satisfy: only order_type, order_date ' \
                         'search criterias allowed but were <{"foo"=>nil}>'
      end
    end
  end
end
