require_relative '../convert_to_type'

module ValidateMyRoutes
  module Validate
    module Rules
      # Rule to validate type of parameter
      module OfType
        ValidateMyRoutes::ValidationRules.def_single_param_validator :of_type do |typ|
          validate do |actual, _|
            begin
              ConvertToType.convert_to_type(actual, typ)
              true
            rescue ValidateMyRoutes::Errors::InvalidTypeError
              false
            end
          end

          description { "of a type <#{typ}>" }

          failure_message do |actual, name|
            "was expected #{name} parameter to be of a type <#{typ}>, but was <#{actual}>"
          end

          failure_message_when_negated do |actual, name|
            "was expected #{name} parameter to not be of a type <#{typ}>, but was <#{actual}>"
          end
        end
      end
    end
  end
end
