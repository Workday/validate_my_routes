require_relative '../../spec_helper'
require 'time'

describe ValidateMyRoutes::Validate::ConvertToType do
  describe '.convert_to_type' do
    subject { described_class.convert_to_type(value, to_type) }

    RSpec.shared_examples 'a successful conversion' do |expected_value|
      it { is_expected.to eql expected_value }
    end

    RSpec.shared_examples 'a failed conversion' do
      it 'fails with InvalidTypeError' do
        expect { subject }.to raise_error(ValidateMyRoutes::Errors::InvalidTypeError)
      end
    end

    context 'with type Boolean' do
      let(:to_type) { :Boolean }

      { 'true' => true, 'false' => false }.each do |parameter_value, expected_result|
        context "with valid value '#{parameter_value}'" do
          let(:value) { parameter_value }
          it_behaves_like 'a successful conversion', expected_result
        end
      end

      context 'with invalid value' do
        let(:value) { 'yes' }
        it_behaves_like 'a failed conversion'
      end
    end

    context 'with type Float' do
      let(:to_type) { Float }

      context 'with valid Float value' do
        let(:value) { '42.67' }
        it_behaves_like 'a successful conversion', 42.67
      end

      context 'with invalid value' do
        let(:value) { '42.5s' }
        it_behaves_like 'a failed conversion'
      end
    end

    context 'with type String' do
      let(:to_type) { String }

      context 'always succeed' do
        let(:value) { 'hi' }
        it_behaves_like 'a successful conversion', 'hi'
      end
    end

    context 'with type Date' do
      let(:to_type) { Date }

      context 'with valid Date value' do
        let(:value) { '2017-07-26' }
        it_behaves_like 'a successful conversion', Date.new(2017, 7, 26)
      end

      context 'with invalid value' do
        let(:value) { '2017+07+26' }
        it_behaves_like 'a failed conversion'
      end
    end

    context 'with type Time' do
      let(:to_type) { Time }

      context 'with valid Time value' do
        let(:value) { '22:34:33' }
        it_behaves_like 'a successful conversion', Time.parse('22:34:33')
      end

      context 'with invalid value' do
        let(:value) { 'hello world' }
        it_behaves_like 'a failed conversion'
      end
    end

    context 'with type DateTime' do
      let(:to_type) { DateTime }

      context 'with valid DateTime value' do
        let(:value) { '2017-07-27 22:34:33' }
        it_behaves_like 'a successful conversion', DateTime.new(2017, 7, 27, 22, 34, 33)
      end

      context 'with invalid value' do
        let(:value) { '2017+07+26' }
        it_behaves_like 'a failed conversion'
      end
    end

    context 'with type Integer' do
      let(:to_type) { Integer }

      context 'with valid Integer value' do
        let(:value) { '42' }
        it_behaves_like 'a successful conversion', 42
      end

      context 'with invalid value' do
        let(:value) { '42.5' }
        it_behaves_like 'a failed conversion'
      end
    end

    context 'with type Array' do
      let(:to_type) { Array }

      context 'with valid Array value (val1,val2,val3)' do
        let(:value) { 'a,b,c' }
        it_behaves_like 'a successful conversion', %w(a b c)
      end

      context 'with empty value' do
        let(:value) { '' }
        it_behaves_like 'a successful conversion', []
      end
    end

    context 'with type Hash' do
      let(:to_type) { Hash }

      context 'with valid Hash value (key1:val1,key2:val2,key3:val3)' do
        let(:value) { 'a:A,b:B,c:C' }
        it_behaves_like 'a successful conversion', { 'a' => 'A', 'b' => 'B', 'c' => 'C' }
      end

      context 'with empty value' do
        let(:value) { '' }
        it_behaves_like 'a successful conversion', {}
      end

      context 'with invalid format value' do
        let(:value) { 'a:b,,::,' }
        it_behaves_like 'a failed conversion'
      end
    end
  end
end
