require 'sinatra/base'
require 'validate_my_routes'

module Examples
  # Simple example application
  class SimpleWithMultipleRoutes < Sinatra::Base
    # Register validate_my_routes Sinatra extension
    register ValidateMyRoutes::Validatable

    # add validation rules
    extend ValidateMyRoutes::ValidationRules

    # Define parameter with validation
    param_validation :order_id, value_as(Integer, between(2, 6))

    post '/orders/:order_id' do |order_id|
      "order with id #{order_id} created"
    end

    get '/orders/:order_id' do |order_id|
      "your order with id #{order_id} is awaiting approval"
    end
  end
end

# Start WEBrick server with our application
Rack::Handler::WEBrick.run Examples::SimpleWithMultipleRoutes.new
