require_relative './validate/validation_rule'

module ValidateMyRoutes
  # Mixin to add custom rules to the application.
  #
  # To create custom rule you can extend your class with ValidationRules:
  #   extend ValidateMyRoutes::ValidationRules
  module ValidationRules
    module_function

    def def_single_param_validator(name, &declarations)
      def_validation_rule name, :single_param, &declarations
    end

    def def_all_params_validator(name, &declarations)
      def_validation_rule name, :all_params, &declarations
    end

    def def_validation_rule(name, typ = :general, &declarations)
      raise Errors::MissingValidationDeclarationBlock unless block_given?
      raise Errors::ValidationRuleNamingConflict, name.to_sym if respond_to? name.to_sym

      rule = ->(*expected) { Validate::ValidationRule.new(name, typ, *expected, declarations) }

      define_method(name, rule)
      define_singleton_method(name, rule)
    end
  end
end
