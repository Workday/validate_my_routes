require_relative '../spec_helper'

VMR_RULES = ValidateMyRoutes::ValidationRules unless defined? VMR_RULES

describe 'ValidateMyRoutes built-in validation rules for all parameters validation' do
  include_context 'with test app including validate my routes'

  describe 'Validation rule `anything`' do
    include_examples 'a valid validation rule', VMR_RULES.anything,
                     all_params: true, single_param: true

    include_context 'with mocked route in test app with parameters validation', 'anything'

    include_examples 'returns rule description in body', 'anything'

    context 'with parameter set to something' do
      let(:query_params) { '?my_param=foo' }
      include_examples 'succeeds validation'
    end

    context 'with parameter not set' do
      let(:query_params) { '' }
      include_examples 'succeeds validation'
    end
  end

  describe 'Validation rule `required`' do
    include_examples 'a valid validation rule', VMR_RULES.required(:q), all_params: true

    include_context 'with mocked route in test app with parameters validation',
                    'required(:my_param)'

    let(:query_params) { '?my_param' }
    include_examples 'returns rule description in body', 'parameter <my_param> is required'

    context 'with required parameter specified' do
      let(:query_params) { '?my_param' }
      include_examples 'succeeds validation'
    end

    context 'with required parameter missing' do
      let(:query_params) { '' }
      include_examples 'fails validation', 400, 'Bad Request',
                       'parameter <my_param> was expected to be present'
    end
  end

  describe 'Validation rules for parameters inclusion' do
    describe 'Validation rule `only_one_of`' do
      include_examples 'a valid validation rule', VMR_RULES.only_one_of(%i[foo bar]),
                       all_params: true

      include_context 'with mocked route in test app with parameters validation',
                      'only_one_of(%i[foo bar])'

      let(:query_params) { '?foo' }

      include_examples 'returns rule description in body', 'only one of <foo, bar> parameters'

      %w[foo bar another].each do |example|
        context "with <#{example}> only provided" do
          let(:query_params) { "?#{example}" }
          include_examples 'succeeds validation'
        end
      end

      context 'with both parameters <foo> and <bar> provided' do
        let(:query_params) { '?foo&bar' }
        include_examples 'fails validation', 400, 'Bad Request',
                         'was expected to have only one of <foo, bar> parameters, but <foo, bar> ' \
                         'were provided'
      end
    end

    describe 'Validation rule `exactly_one_of`' do
      include_examples 'a valid validation rule', VMR_RULES.exactly_one_of(%i[foo bar]),
                       all_params: true

      include_context 'with mocked route in test app with parameters validation',
                      'exactly_one_of(%i[foo bar])'

      let(:query_params) { '?foo' }

      include_examples 'returns rule description in body', 'exactly one of <foo, bar> parameters'

      %w[foo bar].each do |example|
        context "with <#{example}> only provided" do
          let(:query_params) { "?#{example}" }
          include_examples 'succeeds validation'
        end
      end

      context 'with both parameters <foo> and <bar> provided' do
        let(:query_params) { '?foo&bar' }
        include_examples 'fails validation', 400, 'Bad Request',
                         'was expected to have exactly one of <foo, bar> parameters, ' \
                         'but <foo, bar> were provided'
      end

      context 'with none of specified parameters provided' do
        let(:query_params) { '?another' }
        include_examples 'fails validation', 400, 'Bad Request',
                         'was expected to have exactly one of <foo, bar> parameters, ' \
                         'but <another> was provided'
      end
    end

    describe 'Validation rule `at_least_one_of`' do
      include_examples 'a valid validation rule', VMR_RULES.at_least_one_of(%i[foo bar]),
                       all_params: true

      include_context 'with mocked route in test app with parameters validation',
                      'at_least_one_of(%i[foo bar])'

      let(:query_params) { '?foo' }

      include_examples 'returns rule description in body', 'at least one of <foo, bar> parameters'

      %w[foo bar].each do |example|
        context "with <#{example}> only provided" do
          let(:query_params) { "?#{example}" }
          include_examples 'succeeds validation'
        end
      end

      context 'with both parameters <foo> and <bar> provided' do
        let(:query_params) { '?foo&bar' }
        include_examples 'succeeds validation'
      end

      context 'with none of specified parameters provided' do
        let(:query_params) { '?another' }
        include_examples 'fails validation', 400, 'Bad Request',
                         'was expected to have at least one of <foo, bar> parameters, ' \
                         'but <another> was provided'
      end
    end
  end
end
