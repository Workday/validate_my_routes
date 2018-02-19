RSpec.shared_context 'with mocked route in test app with parameters validation' do |validation|
  include_context 'with mocked route in test app', <<-CODE
    all_params_validation #{validation}

    get '/my_path/?' do
      "validation succeeded for rule: \#{#{validation}.description}"
    end
  CODE

  subject { get "/my_path#{query_params}" }
  let(:query_params) { '' }
end
