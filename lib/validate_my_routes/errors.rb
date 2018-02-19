module ValidateMyRoutes
  # Defining errors
  module Errors
    # Base error for validate_my_routes
    class Error < ::RuntimeError; end

    # Raised when type conversion fails
    class InvalidTypeError < Error; end

    # Raised when rule is not following required protocol
    class UnsupportedRuleError < Error; end

    # Raised when using validation DSL and missing validation block
    class MissingValidationDeclarationBlock < Error; end

    # Raised when using validation DSL when validation rule is already defined
    class ValidationRuleNamingConflict < Error; end

    # Raised when rule is missused
    class MissusedRuleError < Error; end

    # Basic error raised for validation failures
    class ValidationError < Error
      attr_reader :status_code, :message
      def initialize(message, status_code)
        super(message)
        @status_code = status_code
        @message = message
      end
    end

    # Raised when soft failure occurs
    class ConditionalValidationError < ValidationError; end

    # Raised when exceptions occurs in validation block
    class ValidationRaisedAnExceptionError < ValidationError
      def initialize(custom_exception, status_code)
        super(custom_exception.to_s, status_code)
      end
    end
  end
end
