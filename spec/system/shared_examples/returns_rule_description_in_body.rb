RSpec.shared_examples 'returns rule description in body' do |rule_description|
  it "returns rule description `#{rule_description}` in body" do
    expect(subject.body).to eql("validation succeeded for rule: #{rule_description}")
  end
end
