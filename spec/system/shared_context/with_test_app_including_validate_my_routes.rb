RSpec.shared_context 'with test app including validate my routes' do
  let(:app) { TestApp.new }

  before(:all) do
    TestApp.amend <<-CODE
      # Register ValidateMyRoutes Sinatra extension
      register ValidateMyRoutes::Validatable

      # Add validation rules on class level
      extend ValidateMyRoutes::ValidationRules

      # Add validation rules on instance level (for in-line validation)
      include ValidateMyRoutes::ValidationRules
    CODE
  end
end
