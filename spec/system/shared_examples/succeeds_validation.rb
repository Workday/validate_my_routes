RSpec.shared_examples 'succeeds validation' do
  it 'succeeds validation' do
    expect(subject).to be_ok
  end
end
