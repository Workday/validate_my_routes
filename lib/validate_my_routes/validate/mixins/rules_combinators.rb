module ValidateMyRoutes
  module Validate
    # Helper functions to provide a DSL for creating validation rules
    module RulesCombinators
      # Negate the rule to validate opposite expectation
      #
      #     is_an_integer = of_type(Integer)
      #     is_not_an_integer = of_type(Integer).negate
      def negate
        ValidateMyRoutes::ValidationRules.not self
      end

      # Chain rule with another one to perform both validations
      # Note that if first rule fails validation, second is ignored
      #
      #     required.and of_type(Integer)
      def and(other_rule)
        ValidateMyRoutes::ValidationRules.and(self, other_rule)
      end

      # Chain rule with another one to perform one or another validations
      # Note that second validation will be performed only if first fails
      #
      #     eql('all').or of_type(Integer)
      def or(other_rule)
        ValidateMyRoutes::ValidationRules.or(self, other_rule)
      end
    end
  end
end
