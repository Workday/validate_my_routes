module ValidateMyRoutes
  module Validate
    # Helper functions to provide a DSL for creating validation rules
    module Macros
      # Define all parameters validation
      #
      # validate do |params|
      #   params.key? 'some_parameter_name'
      # end
      def validate(&block)
        define_method(:validate, &block)
      end

      # Customize validation rule description
      #
      # description do
      #   'this is my custom validation rule description'
      # end
      def description(&block)
        define_method(:description, &block)
      end

      # Customize message returned when validation fails for all parameters
      #
      # failure_message do |params|
      #   "oh no! validation failed for #{params}"
      # end
      def failure_message(&block)
        define_method(:failure_message, &block)
      end

      # Customize message returned when opposite rule validation fails (not of type A)
      #
      # failure_message_when_negated do |params|
      #   "oh no! validation failed for #{params}, but it was not expected"
      # end
      def failure_message_when_negated(&block)
        define_method(:failure_message_when_negated, &block)
      end

      # Customize http status code of the failure
      #
      # failure_code do |in_path|
      #   in_path ? 404 : 400
      # end
      def failure_code(&block)
        define_method(:failure_code, &block)
      end
    end
  end
end
