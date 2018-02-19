RSpec.shared_examples 'a valid validation rule' do |rule, options|
  let(:all_params) { options[:all_params] }
  let(:single_param) { options[:single_param] }

  it "#{options[:all_params] ? 'can' : 'can not'} be used for all parameters validation" do
    expected_result = all_params == true
    expect(ValidateMyRoutes::Validate::Rules.all_params_rule?(rule)).to eql(expected_result)
  end

  it "#{options[:single_param] ? 'can' : 'can not'} be used for single parameter validation" do
    expected_result = single_param == true
    expect(ValidateMyRoutes::Validate::Rules.single_param_rule?(rule)).to eql(expected_result)
  end
end
