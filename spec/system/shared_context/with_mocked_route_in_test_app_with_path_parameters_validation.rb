RSpec.shared_context 'with mocked route in test app with path params validation' do |validation|
  include_context 'with mocked route in test app', <<-CODE
    param_validation :my_param, #{validation}

    get '/my_path/:my_param' do |my_param|
      "validation succeeded for rule: \#{#{validation}.description}"
    end
  CODE

  subject { get "/my_path/#{path_param}" }
  let(:path_param) { '' }
end
