require_relative '../spec_helper.rb'
require 'rack/test'

require_relative '../support/test_app'

require_relative './shared_context/with_test_app_including_validate_my_routes'
require_relative './shared_context/with_mocked_route_in_test_app'
require_relative './shared_context/with_mocked_route_in_test_app_with_parameters_validation'
require_relative './shared_context/with_mocked_route_in_test_app_with_path_parameters_validation'

require_relative './shared_examples/a_valid_validation_rule'
require_relative './shared_examples/fails_validation'
require_relative './shared_examples/succeeds_validation'
require_relative './shared_examples/returns_rule_description_in_body'

RSpec.configure do |config|
  config.include Rack::Test::Methods
end
