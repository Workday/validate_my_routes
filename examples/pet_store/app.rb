require 'sinatra/base'
require 'validate_my_routes'
require 'json'

module Examples
  # My example application
  class PetStore < Sinatra::Base
    # Register validate_my_routes Sinatra extension
    register ValidateMyRoutes::Validatable

    # add validation rules
    extend ValidateMyRoutes::ValidationRules

    # custom validation for json pet value with specified status
    def_all_params_validator :is_a_pet_with_status do |expected_status|
      # define actual validation of received value
      validate do |json|
        extra_props = json.keys - %w[status name]
        extra_props.empty? && json['status'] == expected_status
      end

      # changing description from default 'custom created rule is_a_pet_with_status'
      description do
        "a pet with status #{expected_status}"
      end

      # changing failure message from default
      # "was expected to satisfy: #{description} but was <#{actual}>"
      failure_message do |actual|
        "expected to receive json pet with status #{expected_status}, but was #{actual.to_json}"
      end
    end

    # Just for the simplicity initializing in-memory store for pets as a simple hash
    def initialize
      @store = {}
      super
    end

    VALID_STATUSES = %w[available unavailable sold].freeze

    # As our application supports only json body type, we will parse JSON object before processing
    # the request to have parsed object in @request_body
    before do
      request.body.rewind
      body = request.body.read
      body = '{}' if body.nil? || body == ''
      @request_body = JSON.parse(body)
    end

    # custom validation for validating get pets search criteria
    def_all_params_validator :get_pets_validation do
      validate do |params|
        # validate that status is one of valid statuses if provided
        check(self, from_enum(VALID_STATUSES), params['status'], false) if params.key?('status')
        true
      end
    end

    all_params_validation get_pets_validation
    # route to retrieve all pets we have in pet store
    get '/pet/?' do
      return @store.values.to_json unless params['status']

      @store.select { |_id, pet| pet[:status] == params['status'] }.values.to_json
    end

    post '/pet' do
      # Use in-place validation for body
      rule = is_a_pet_with_status('available')
      ValidateMyRoutes::Validate.validate!(self, rule, @request_body, false) do |msg|
        halt 400, "Body is #{msg}"
      end

      pet = { name: @request_body['name'], status: @request_body['status'] }

      pet[:id] = @store.length
      @store[pet[:id]] = pet

      pet[:id].to_json
    end

    # Define parameter with validation to re-use across all routes for single
    # parameter validation
    param_validation :pet_id, of_type(Integer)

    get '/pet/:pet_id' do |pet_id|
      halt 404, "Pet with id #{pet_id} not found" unless @store.key? pet_id.to_i

      @store[pet_id.to_i].to_json
    end

    delete '/pet/:pet_id' do |pet_id|
      halt 404, "Pet with id #{pet_id} not found" unless @store.key? pet_id.to_i

      @store.delete(pet_id.to_i).to_json
    end
  end
end

# Start WEBrick server with our application
Rack::Handler::WEBrick.run Examples::PetStore.new
