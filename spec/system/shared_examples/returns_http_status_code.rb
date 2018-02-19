RSpec.shared_examples 'returns http status code' do |status_code, status_message|
  it "returns #{status_code} #{status_message}" do
    expect(subject.status).to eql(status_code)
  end
end
