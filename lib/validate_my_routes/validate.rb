require_relative 'validate/convert_to_type'
require_relative 'validate/rules'

module ValidateMyRoutes
  # Module for validation. Provides method to validate value by specified rule.
  module Validate
    class << self
      # Perform validation of a single rule in-place
      # Note: this method is not validating that rule is for all parameters or just a single
      # Example:
      #
      #    get 'some/:id' do |id|
      #      ValidateMyRoutes::Validate.validate!(self, greater_than(5), id.to_i, 'id') do |msg|
      #        halt 400, "Id <#{id}> failed validation: #{msg}"
      #      end
      #    end
      def validate!(app, rule, *args)
        rule.validate!(app, *args)
      rescue Errors::ConditionalValidationError
        false
      rescue Errors::ValidationError => failure
        app.halt failure.status_code, failure.message unless block_given?
        yield failure.message
      end
    end
  end
end
