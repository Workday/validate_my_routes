require 'sinatra/base'
require 'doc_my_routes'
require 'validate_my_routes'

module Examples
  # My example application
  class AppWithDocumentation < Sinatra::Base
    # Register doc_my_routes Sinatra extension for documentation
    register DocMyRoutes::Annotatable

    # Register validate_my_routes Sinatra extension
    register ValidateMyRoutes::Validatable

    # Add validation rules to class level to use with define_path_parameter
    extend ValidateMyRoutes::ValidationRules

    # Add validation rules to instance level to use inside validation rule definitions
    # i.e. inside define_validator
    include ValidateMyRoutes::ValidationRules # add validation rules

    # Saving validation rule in variable so we can use it in notes for the route documentation
    order_id_validation = value_as(Integer, between(2, 6))
    # Add validation for order_id parameter
    param_validation :order_id, order_id_validation

    # Just for the simplicity initializing in-memory store for orders as a simple hash
    def initialize
      @store = {}
      super
    end

    summary 'Create new order with specified id'
    status_codes [204, 400, 404]
    parameter :order_id, in: :path, description: "Id of the created order"
    notes "includes validation for order_id parameter: #{order_id_validation.description}"
    post '/orders/:order_id' do |order_id|
      id = order_id.to_i
      halt 400, "order with id #{id} already exists" if @store.key?(id)

      @store[id] = "order #{id}"

      redirect "/orders/#{id}", 204
    end

    summary "Get an order by it's id"
    status_codes [200, 404]
    parameter :order_id, in: :path, description: "Id of the created order"
    notes "includes validation for order_id parameter: #{order_id_validation.description}"
    get '/orders/:order_id' do |order_id|
      id = order_id.to_i
      halt 404, "order with id #{id} not found" unless @store.key?(id)

      @store[id]
    end

    def_all_params_validator :searchable_by_partial_id do
      validate do |params|
        check(of_type(Integer), params['partial_id'], 'partial_id') if params.key? 'partial_id'
      end

      description { 'partial_id of type Integer if present' }
    end

    summary 'Find orders'
    status_codes [200, 404]
    parameter :'query string', in: :query,
                               description: 'Optional search criteria to search by partial id'
    notes "includes validation for partial_id parameter: #{searchable_by_partial_id.description}"
    all_params_validation searchable_by_partial_id
    get '/orders' do
      orders = @store.dup
      orders.select! { |id, _| id.to_s.include?(params['partial_id']) } if params['partial_id']
      orders.values.to_s
    end
  end
end

DocMyRoutes.configure do |config|
  config.title = 'Example application'
  config.description = 'Sinatra application with parameters validation and documentation'
end

DocMyRoutes::Documentation.generate
Rack::Handler::WEBrick.run Examples::AppWithDocumentation.new
