module ValidateMyRoutes
  module Validate
    module Rules
      # Rules combinators
      # TODO: add validations to the rules before combining them
      module Compound
        ValidateMyRoutes::ValidationRules.def_validation_rule :not do |rule|
          validate do |*args|
            begin
              !check(rule, *args)
            rescue Errors::ValidationError
              true
            end
          end

          failure_message { |*args| rule.failure_message_when_negated(*args) }
          failure_message_when_negated { |*args| rule.failure_message(*args) }
          description { "NOT #{rule.description}" }
          failure_code { |*args| rule.failure_code(*args) }
        end

        ValidateMyRoutes::ValidationRules.def_validation_rule :and do |first_rule, second_rule|
          validate { |*args| check(first_rule, *args) && check(second_rule, *args) }
          description { "(#{first_rule.description} AND #{second_rule.description})" }
        end

        ValidateMyRoutes::ValidationRules.def_validation_rule :or do |first_rule, second_rule|
          validate do |*args|
            begin
              check(first_rule, *args) || check(second_rule, *args)
            rescue Errors::ValidationError
              check(second_rule, *args)
            end
          end

          description { "(#{first_rule.description} OR #{second_rule.description})" }
        end
      end
    end
  end
end
