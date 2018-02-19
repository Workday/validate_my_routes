require 'uri'
require_relative '../spec_helper'

VMR_RULES = ValidateMyRoutes::ValidationRules unless defined? VMR_RULES

describe 'ValidateMyRoutes built-in validation rules for single parameter validation' do
  include_context 'with test app including validate my routes'

  describe 'Validation rule `anything`' do
    include_examples 'a valid validation rule', VMR_RULES.anything,
                     single_param: true, all_params: true

    include_context 'with mocked route in test app with path params validation', 'anything'

    context 'with parameter set to something' do
      let(:path_param) { 'foo' }
      include_examples 'returns rule description in body', 'anything'
      include_examples 'succeeds validation'
    end
  end

  describe 'Validation rule `from_enum`' do
    include_examples 'a valid validation rule', VMR_RULES.from_enum([:q]), single_param: true

    include_context 'with mocked route in test app with path params validation',
                    'from_enum(%w(foo bar))'

    let(:path_param) { 'foo' }
    include_examples 'returns rule description in body', 'of enum type with values: foo, bar'

    %w(foo bar).each do |param_value|
      context "with parameter set to #{param_value}" do
        let(:path_param) { param_value }
        include_examples 'succeeds validation'
      end
    end

    context 'with parameter set to something else' do
      let(:path_param) { 'foobar' }
      include_examples 'fails validation', 404, 'Not Found',
                       'parameter <my_param> was expected to have one of following values: ' \
                       '<foo, bar>, but was <foobar>'
    end
  end

  describe 'Validation rules for comparison' do
    shared_examples 'comparable validation rule' \
      do |rule, rule_description, passing, failing, failing_message|

      include_context 'with mocked route in test app with path params validation', rule

      let(:path_param) { passing.first }
      include_examples 'returns rule description in body', rule_description

      passing.each do |parameter_value|
        context "with parameter set to `#{parameter_value}`" do
          let(:path_param) { parameter_value }
          include_examples 'succeeds validation'
        end
      end

      failing.each do |parameter_value|
        context "with parameter set to `#{parameter_value}`" do
          let(:path_param) { parameter_value }
          include_examples 'fails validation', 404, 'Not Found',
                           "was expected my_param parameter to #{failing_message}, " \
                           "but was <#{parameter_value}>"
        end
      end
    end

    describe 'Validation rule `eql`' do
      include_examples 'a valid validation rule', VMR_RULES.eql('foo'), single_param: true

      include_examples 'comparable validation rule',
                       "eql('foo')", 'equal to <foo>',
                       %w(foo), %w(bar), 'equal <foo>'
    end

    describe 'Validation rule `greater_than`' do
      include_examples 'a valid validation rule', VMR_RULES.greater_than(5), single_param: true

      include_examples 'comparable validation rule',
                       'value_as(Integer, greater_than(5))', 'greater than <5>',
                       %w(10), %w(5 2), 'be greater than <5>'
    end

    describe 'Validation rule `greater_than_or_equal_to`' do
      include_examples 'a valid validation rule', VMR_RULES.greater_than_or_equal_to(5),
                       single_param: true

      include_examples 'comparable validation rule',
                       'value_as(Integer, greater_than_or_equal_to(5))',
                       'greater than or equal to <5>',
                       %w(10 5), %w(2), 'be greater than or equal to <5>'
    end

    describe 'Validation rule `less_than`' do
      include_examples 'a valid validation rule', VMR_RULES.less_than(5), single_param: true

      include_examples 'comparable validation rule',
                       'value_as(Integer, less_than(5))', 'less than <5>',
                       %w(2), %w(5 10), 'be less than <5>'
    end

    describe 'Validation rule `less_than_or_equal_to`' do
      include_examples 'a valid validation rule', VMR_RULES.less_than_or_equal_to(5),
                       single_param: true

      include_examples 'comparable validation rule',
                       'value_as(Integer, less_than_or_equal_to(5))', 'less than or equal to <5>',
                       %w(2 5), %w(10), 'be less than or equal to <5>'
    end

    describe 'Validation rule `between`' do
      include_examples 'a valid validation rule', VMR_RULES.between(5, 10), single_param: true

      include_examples 'comparable validation rule',
                       'value_as(Integer, between(5, 10))', 'between <5> and <10>',
                       %w(5 7 10), %w(2 15), 'be between <5> and <10>'
    end
  end

  describe 'Validation rule `of_type`' do
    shared_examples 'type validation rule' do |parameter_type, passing, failing|
      type_name = parameter_type[/\w+/]

      include_context 'with mocked route in test app', <<-CODE
        param_validation :my_param, of_type(#{parameter_type})

        get '/my_path/:my_param' do
          "validation succeeded for rule: \#{of_type(#{parameter_type}).description}"
        end
      CODE

      subject { get "/my_path/#{my_param}" }
      let(:my_param) { URI.escape(passing.first) }

      include_examples 'returns rule description in body', "of a type <#{type_name}>"

      passing.each do |parameter_value|
        context "with parameter set to `#{parameter_value}`" do
          let(:my_param) { URI.escape(parameter_value) }
          include_examples 'succeeds validation'
        end
      end

      failing.each do |parameter_value|
        context "with parameter set to `#{parameter_value}`" do
          let(:my_param) { URI.escape(parameter_value) }
          include_examples 'fails validation', 404, 'Not Found',
                           "was expected my_param parameter to be of a type <#{type_name}>, " \
                           "but was <#{parameter_value}>"
        end
      end
    end

    describe 'for type `String` _(similar to anything as any object can be converted to String)_' do
      include_examples 'type validation rule', 'String', %w(foo 15), []
    end

    [
      ['Integer', %w(15), %w(foo 15.3)],
      ['Float', %w(15.3 15), %w(foo)],
      ['Date', ['2017-07-26'], ['foo']],
      ['Time', ['22:34:33'], ['foo']],
      ['DateTime', ['2017-07-27 22:34:33'], ['foo']],
      ['Array', ['1,2,3'], []],
      ['Hash', ['a:A,b:B,c:C'], ['a:b,,::,']],
      [':Boolean', %w(true false TrUe FAlsE), %w(1 0 y n foo)]
    ].each do |sample|
      describe "for type `#{sample.first}`" do
        include_examples 'type validation rule', *sample
      end
    end
  end
end
