require_relative 'validation_rule'

require_relative 'rules/compound'
require_relative 'rules/anything'
require_relative 'rules/comparable'
require_relative 'rules/conditional'
require_relative 'rules/of_type'
require_relative 'rules/required'
require_relative 'rules/transforms'
require_relative 'rules/enum'
require_relative 'rules/all_parameters'

module ValidateMyRoutes
  module Validate
    # Module provides methods to validate if rule is a rule and if it can be used for single
    # or all parameters validation.
    module Rules
      class << self
        REQUIRED_RULE_METHODS = %i(validate! description rule_type).freeze

        def single_param_rule?(rule)
          validation_rule?(rule) && %i(single_param general).include?(rule.rule_type)
        end

        def all_params_rule?(rule)
          validation_rule?(rule) && %i(all_params general).include?(rule.rule_type)
        end

        # Validate that rule can be used for single parameter validation
        #
        # Example:
        #
        #    Rules.validate_single_param_rule! required(:q) # => throws an exception
        def validate_single_param_rule!(rule)
          unless Rules.single_param_rule?(rule)
            raise ValidateMyRoutes::Errors::UnsupportedRuleError,
                  "rule #{rule} must implement #{REQUIRED_RULE_METHODS.join(', ')} " \
                  'and be either :generic or :single_param rule type.'
          end
        end

        # Validate that rule can be used for all parameters validation
        #
        # Example:
        #
        #    Rules.validate_all_params_rule! of_type(Integer) # => throws an exception
        def validate_all_params_rule!(rule)
          unless Rules.all_params_rule?(rule)
            raise ValidateMyRoutes::Errors::UnsupportedRuleError,
                  "rule #{rule} must implement #{REQUIRED_RULE_METHODS.join(', ')} " \
                  'and be either :generic or :all_params rule type.'
          end
        end

        private

        def validation_rule?(rule)
          REQUIRED_RULE_METHODS.all? { |method_name| rule.respond_to? method_name }
        end
      end
    end
  end
end
