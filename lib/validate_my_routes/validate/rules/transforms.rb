module ValidateMyRoutes
  module Validate
    module Rules
      # Rules that perform transformation of value before sending it to another rule
      module Transforms
        ValidateMyRoutes::ValidationRules.def_single_param_validator :value_as do |typ, rule|
          validate do |actual, name|
            begin
              converted_value = ConvertToType.convert_to_type(actual, typ)
              check(rule, converted_value, name)
            rescue ValidateMyRoutes::Errors::InvalidTypeError
              false
            end
          end

          description { rule.description }

          failure_message do |actual, name|
            "was expected #{name} parameter to be of type <#{typ}>, but was <#{actual}>"
          end

          failure_message_when_negated do |_, _|
            # TODO: make sure that not(value_as(...)) can not be used instead of failing here
            raise Errors::MissusedRuleError, 'value_as does not support negate operation'
          end

          failure_code { |*args| rule.failure_code(*args) }
        end

        ValidateMyRoutes::ValidationRules.def_validation_rule :transform do |transformation, rule|
          description { rule.description }
          validate do |*args|
            if args.size == 2
              # this means single parameter validation with value and name
              check(rule, transformation.call(args[0]), args[1])
            elsif args.size == 1
              # this means all parameters validation with value only
              check(rule, transformation.call(args[0]))
            else
              raise Errors::MissusedRuleError, "Received #{args.size} instead of 1 or 2"
            end
          end
          failure_message { |*args| rule.failure_message(*args) }
          failure_message_when_negated { |*args| rule.failure_message_when_negated(*args) }
          failure_code { |*args| rule.failure_code(*args) }
        end
      end
    end
  end
end
