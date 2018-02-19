RSpec.shared_context 'with mocked route in test app' do |route_code|
  before(:context) { TestApp.amend route_code }
  after(:context) { TestApp.reset! }
end
