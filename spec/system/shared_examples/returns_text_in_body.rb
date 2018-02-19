RSpec.shared_examples 'returns text in body' do |body_text|
  it "returns `#{body_text}` in body" do
    expect(subject.body).to eql(body_text)
  end
end
