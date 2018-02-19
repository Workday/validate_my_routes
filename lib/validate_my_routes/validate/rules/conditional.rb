module ValidateMyRoutes
  module Validate
    module Rules
      # Validation rule that on failure instruct Sinatra to search for another route instead of
      # failing with validation error
      module Conditional
        ValidateMyRoutes::ValidationRules.def_validation_rule :conditional do |rule|
          validate do |*args|
            begin
              check(rule, *args)
            rescue Errors::ValidationError => error
              raise Errors::ConditionalValidationError.new(error.message, error.status_code)
            end
          end

          description { "conditional, #{rule.description}" }
        end
      end
    end
  end
end
