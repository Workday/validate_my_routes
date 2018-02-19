require_relative '../spec_helper'

describe 'ValidateMyRoutes validation rules combinators' do
  include_context 'with test app including validate my routes'

  describe 'Combinator `and`' do
    include_context 'with mocked route in test app with path params validation',
                    "of_type(Integer).and(eql('5'))"

    let(:path_param) { '5' }
    include_examples 'returns rule description in body', '(of a type <Integer> AND equal to <5>)'

    context 'with parameter satisfying both validations (5)' do
      let(:path_param) { '5' }
      include_examples 'succeeds validation'
    end

    context 'with parameter failing first rule (foo)' do
      let(:path_param) { 'foo' }
      include_examples 'fails validation', 404, 'Not Found',
                       'was expected my_param parameter to be of a type <Integer>, but was <foo>'
    end

    context 'with parameter failing second rule (15)' do
      let(:path_param) { '15' }
      include_examples 'fails validation', 404, 'Not Found',
                       'was expected my_param parameter to equal <5>, but was <15>'
    end
  end

  describe 'Combinator `or`' do
    include_context 'with mocked route in test app with path params validation',
                    "eql('foo').or(eql('bar'))"

    let(:path_param) { 'foo' }
    include_examples 'returns rule description in body', '(equal to <foo> OR equal to <bar>)'

    context 'with parameter satisfying first rule (foo)' do
      let(:path_param) { 'foo' }
      include_examples 'succeeds validation'
    end

    context 'with parameter satisfying second rule (bar)' do
      let(:path_param) { 'bar' }
      include_examples 'succeeds validation'
    end

    context 'with parameter failing both rules (another)' do
      let(:path_param) { 'another' }
      include_examples 'fails validation', 404, 'Not Found',
                       'was expected my_param parameter to equal <bar>, but was <another>'
    end
  end

  describe 'Combinator `not`' do
    include_context 'with mocked route in test app with path params validation',
                    "eql('foo').negate"

    let(:path_param) { 'bar' }
    include_examples 'returns rule description in body', 'NOT equal to <foo>'

    context 'with parameter satisfying negated rule (bar)' do
      let(:path_param) { 'bar' }
      include_examples 'succeeds validation'
    end

    context 'with parameter failing both rules (foo)' do
      let(:path_param) { 'foo' }
      include_examples 'fails validation', 404, 'Not Found',
                       'was expected my_param parameter to not equal <foo>, but was <foo>'
    end
  end
end
