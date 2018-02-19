require_relative '../spec_helper'

describe 'ValidateMyRoutes custom validation' do
  include_context 'with test app including validate my routes'

  describe 'In-line validation' do
    include_context 'with mocked route in test app', <<-CODE
      post '/my_path' do
        body = request.body.read

        ValidateMyRoutes::Validate.validate!(self, of_type(Integer), body, false, 'body') do |msg|
          halt 401, "not authorised because \#{msg}"
        end

        'OK!'
      end
    CODE

    subject { post '/my_path', data }

    context 'with valid data' do
      let(:data) { '5' }
      include_examples 'succeeds validation'
    end

    context 'with invalid data' do
      let(:data) { 'foo' }
      include_examples 'fails validation', 401, 'Unauthorized (as specified in route code)',
                       'not authorised because was expected body parameter to be ' \
                       'of a type <Integer>, but was <foo>'
    end
  end

  describe 'Conditional validation' do
    include_context 'with mocked route in test app', <<-CODE
      param_validation :my_param, conditional(eql('foo'))
      get '/my_path/:my_param' do |_|
        "validation succeeded for rule: \#{conditional(eql('foo')).description}"
      end

      param_validation :my_param, anything
      get '/my_path/:my_param' do |_|
        "another path choosen after conditional validation failed"
      end
    CODE

    subject { get "/my_path/#{my_param}" }

    context 'with my_param set to "foo"' do
      let(:my_param) { 'foo' }
      include_examples 'succeeds validation'
      include_examples 'returns rule description in body', 'conditional, equal to <foo>'
    end

    context 'with parameter set to "bar"' do
      let(:my_param) { 'bar' }
      include_examples 'succeeds validation'

      it 'returns text from second route' do
        expect(subject.body).to eql('another path choosen after conditional validation failed')
      end
    end
  end

  describe 'URL vs QUERY STRING parameters' do
    include_context 'with mocked route in test app', <<-CODE
      param_validation :path_parameter, eql('foo')

      all_params_validation required(:query_parameter)
      get '/my_path/:path_parameter' do
        'OK!'
      end
    CODE

    subject { get "/my_path/#{path_parameter}#{query_string}" }

    let(:path_parameter) { '' }
    let(:query_string) { '' }

    context 'when path and query string parameters are invalid' do
      let(:path_parameter) { 'bar' }
      let(:query_string) { '' }

      include_examples 'fails validation', 404, 'Not Found',
                       'was expected path_parameter parameter to equal <foo>, but was <bar>'
    end

    context 'when path parameter is valid but query string parameters is invalid' do
      let(:path_parameter) { 'foo' }
      let(:query_string) { '' }

      include_examples 'fails validation', 400, 'Bad Request',
                       'parameter <query_parameter> was expected to be present'
    end

    context 'with both parameters valid' do
      let(:path_parameter) { 'foo' }
      let(:query_string) { '?query_parameter' }

      include_examples 'succeeds validation'
    end
  end

  describe 'custom validation' do
    describe 'for single parameter validation' do
      subject { get "/my_path/#{my_param}" }
      let(:my_param) { 'foo' }

      describe 'with only required declaration used' do
        include_context 'with mocked route in test app', <<-CODE
          def_single_param_validator :custom_eql do |expected|
            validate { |actual, name| actual == expected }
          end

          param_validation :my_param, custom_eql('foo')

          get '/my_path/:my_param' do |my_param|
            "validation succeeded for rule: \#{custom_eql('foo').description}"
          end
        CODE

        include_examples 'returns rule description in body', 'Custom eql'

        context 'with invalid data used' do
          let(:my_param) { 'bar' }

          include_examples 'fails validation', 404, 'Not Found',
                           'parameter my_param was expected to satisfy: Custom eql but was <bar>'
        end

        describe 'when used as negated rule' do
          include_context 'with mocked route in test app', <<-CODE
            param_validation :my_param_2, custom_eql('foo').negate

            get '/my_path_2/:my_param_2' do |my_param_2|
              "validation succeeded for rule: \#{custom_eql('foo').negate.description}"
            end
          CODE

          subject { get "/my_path_2/#{my_param_2}" }
          let(:my_param_2) { 'bar' }

          include_examples 'returns rule description in body', 'NOT Custom eql'

          context 'with invalid data used' do
            let(:my_param_2) { 'foo' }

            include_examples 'fails validation', 404, 'Not Found',
                             'parameter my_param_2 was expected not to satisfy: Custom eql ' \
                             'but was <foo>'
          end
        end
      end

      describe 'with everything overriden' do
        include_context 'with mocked route in test app', <<-CODE
          def_single_param_validator :custom_eql_with_overrides do |expected|
            validate do |actual, name|
              actual == expected
            end

            description do
              "custom description with expected \#{expected}"
            end

            failure_message do |actual, name|
              "custom failure for \#{name} with expected \#{expected} and actual \#{actual}"
            end

            failure_message_when_negated do |actual, name|
              "custom negated failure for \#{name} with expected \#{expected} and actual \#{actual}"
            end

            failure_code do |parameter_is_in_path|
              parameter_is_in_path ? 401 : 409
            end
          end

          param_validation :my_param, custom_eql_with_overrides('foo')

          get '/my_path/:my_param' do |my_param|
            "validation succeeded for rule: \#{custom_eql_with_overrides('foo').description}"
          end
        CODE

        include_examples 'returns rule description in body', 'custom description with expected foo'

        context 'with invalid data used' do
          let(:my_param) { 'bar' }

          include_examples 'fails validation', 401, 'Our custom defined code',
                           'custom failure for my_param with expected foo and actual bar'
        end

        describe 'when used as negated rule' do
          include_context 'with mocked route in test app', <<-CODE
            param_validation :my_param_2, custom_eql_with_overrides('foo').negate

            get '/my_path_2/:my_param_2' do |my_param_2|
              rule = custom_eql_with_overrides('foo').negate
              "validation succeeded for rule: \#{rule.description}"
            end
          CODE

          subject { get "/my_path_2/#{my_param_2}" }
          let(:my_param_2) { 'bar' }

          include_examples 'returns rule description in body',
                           'NOT custom description with expected foo'

          context 'with invalid data used' do
            let(:my_param_2) { 'foo' }

            include_examples 'fails validation', 401, 'Our custom defined code',
                             'custom negated failure for my_param_2 with expected ' \
                             'foo and actual foo'
          end
        end
      end
    end

    describe 'for all parameters validation' do
      subject { get "/my_path?#{query_params}" }
      let(:query_params) { 'my_param' }

      describe 'with only required declaration used' do
        include_context 'with mocked route in test app', <<-CODE
          def_all_params_validator :custom_required do |expected|
            validate { |params| params.key? expected }
          end

          all_params_validation custom_required('my_param')

          get '/my_path' do
            "validation succeeded for rule: \#{custom_required('my_param').description}"
          end
        CODE

        include_examples 'returns rule description in body', 'Custom required'

        context 'with invalid data used' do
          let(:query_params) { 'not_my_param' }

          include_examples 'fails validation', 400, 'Bad Request',
                           'parameters were expected to satisfy: Custom required ' \
                           'but were <{"not_my_param"=>nil}>'
        end

        describe 'when used as negated rule' do
          include_context 'with mocked route in test app', <<-CODE
            all_params_validation custom_required('my_param_2').negate
            get '/my_path_2' do
              rule = custom_required('my_param_2').negate
              "validation succeeded for rule: \#{rule.description}"
            end
          CODE

          subject { get "/my_path_2?#{query_params}" }
          let(:query_params) { 'not_my_param_2' }

          include_examples 'returns rule description in body', 'NOT Custom required'

          context 'with invalid data used' do
            let(:query_params) { 'my_param_2' }

            include_examples 'fails validation', 400, 'Bad Request',
                             'parameters were expected not to satisfy: Custom required ' \
                             'but were <{"my_param_2"=>nil}>'
          end
        end
      end

      describe 'with everything overriden' do
        include_context 'with mocked route in test app', <<-CODE
          def_all_params_validator :custom_required_with_overrides do |expected|
            validate do |params|
              params.key? expected
            end

            description do
              "custom description with expected \#{expected}"
            end

            failure_message do |params|
              "custom failure for expected \#{expected} and params \#{params}"
            end

            failure_message_when_negated do |params|
              "custom negated failure for expected \#{expected} and params \#{params}"
            end

            failure_code do |parameter_is_in_path|
              parameter_is_in_path ? 401 : 409
            end
          end

          all_params_validation custom_required_with_overrides('my_param')
          get '/my_path' do
            rule = custom_required_with_overrides('my_param')
            "validation succeeded for rule: \#{rule.description}"
          end
        CODE

        include_examples 'returns rule description in body',
                         'custom description with expected my_param'

        context 'with invalid data used' do
          let(:query_params) { 'not_my_param' }

          include_examples 'fails validation', 409, 'Our custom defined code',
                           'custom failure for expected my_param and params {"not_my_param"=>nil}'
        end

        describe 'when used as negated rule' do
          include_context 'with mocked route in test app', <<-CODE
            all_params_validation custom_required_with_overrides('my_param_2').negate

            get '/my_path_2' do
              rule = custom_required_with_overrides('my_param_2').negate
              "validation succeeded for rule: \#{rule.description}"
            end
          CODE

          subject { get "/my_path_2?#{query_params}" }
          let(:query_params) { 'not_my_param_2' }

          include_examples 'returns rule description in body',
                           'NOT custom description with expected my_param_2'

          context 'with invalid data used' do
            let(:query_params) { 'my_param_2' }

            include_examples 'fails validation', 409, 'Our custom defined code',
                             'custom negated failure for expected my_param_2 and ' \
                             'params {"my_param_2"=>nil}'
          end
        end
      end
    end

    describe 'with using built-in validation rules inside custom validation rule' do
      subject { get "/my_path/#{my_param}" }
      let(:my_param) { 'foo' }

      include_context 'with mocked route in test app', <<-CODE
        def_single_param_validator :with_build_in_eql_to do |expected|
          validate do |actual, name|
            check(ValidateMyRoutes::ValidationRules.eql(expected), actual, name)
          end
        end

        param_validation :my_param, with_build_in_eql_to('foo')
        get '/my_path/:my_param' do
          "validation succeeded for rule: \#{with_build_in_eql_to('foo').description}"
        end
      CODE

      let(:my_param) { 'foo' }
      include_examples 'returns rule description in body',
                       'With build in eql to'

      context 'with valid data passed in' do
        let(:my_param) { 'foo' }
        include_examples 'succeeds validation'
      end

      context 'with invalid data passed in' do
        let(:my_param) { 'bar' }

        include_examples 'fails validation', 404, 'Not Found',
                         'was expected my_param parameter to equal <foo>, but was <bar>'
      end
    end

    describe 'can access application scope' do
      subject { get '/my_path' }

      include_context 'with mocked route in test app', <<-CODE
        def services
          'my services'
        end

        def_all_params_validator :can_access_app_scope do
          validate { |_| services == 'my services' }
        end

        all_params_validation can_access_app_scope
        get '/my_path' do
          'OK!'
        end
      CODE

      include_examples 'succeeds validation'
    end
  end
end
