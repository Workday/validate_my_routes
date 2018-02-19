require 'sinatra/base'
require 'validate_my_routes'

module Examples
  # Simple example application
  class Simple < Sinatra::Base
    # Register validate_my_routes Sinatra extension
    register ValidateMyRoutes::Validatable

    # Define parameter with validation
    param_validation :my_param, ValidateMyRoutes::ValidationRules.of_type(Integer)

    get '/:my_param' do
      "my parameter with value #{params['my_param']} was validated!"
    end
  end
end

# Start WEBrick server with our application
Rack::Handler::WEBrick.run Examples::Simple.new
