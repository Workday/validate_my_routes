require_relative 'mixins/macros'
require_relative 'mixins/rules_combinators'

module ValidateMyRoutes
  module Validate
    # ValidationRule is a base class for all rules
    class ValidationRule
      # Add DSL support for declarations in constructor
      extend Macros
      include RulesCombinators

      attr_reader :rule_type

      def initialize(rule_name, rule_type, *expected, declarations)
        self.rule_name = rule_name
        self.rule_type = rule_type
        self.app = nil # this is a Sinatra application instance
        singleton_class.class_exec(*expected, &declarations)
      end

      # Current method can be used for validation
      def validate!(app, value, path_param, *args)
        # save current Sinatra app instance for method lookup on it
        self.app = app

        self.value = value
        self.path_param = path_param == true

        validate(value, *args) || fail_validation(failure_message(value, *args))
      rescue Errors::ValidationError
        # validation failed, so just re-raise an error to buble it up to the root
        # re-raising is needed in order to catch all other exceptions to wrap them in
        # special error
        raise
      rescue => ex # rubocop:disable Style/RescueStandardError
        # unexpected exception happened in validation block, so we should wrap it in special error
        raise Errors::ValidationRaisedAnExceptionError.new(ex, failure_code(path_param?))
      end

      def validate(*_args)
        raise Errors::MissusedRuleError, 'validate method not implemented'
      end

      def description
        rule_name.to_s.capitalize.tr('_', ' ')
      end

      def failure_code(in_path)
        in_path ? 404 : 400
      end

      def failure_message(*args)
        if args.size == 1
          "parameters were expected to satisfy: #{description} but were <#{args[0]}>"
        elsif args.size == 2
          "parameter #{args[1]} was expected to satisfy: #{description} but was <#{args[0]}>"
        else
          raise Errors::MissusedRuleError, "failure_message method called with #{args.size} " \
                                           'arguments'
        end
      end

      def failure_message_when_negated(*args)
        if args.size == 1
          "parameters were expected not to satisfy: #{description} but were <#{args[0]}>"
        elsif args.size == 2
          "parameter #{args[1]} was expected not to satisfy: #{description} but was <#{args[0]}>"
        else
          raise Errors::MissusedRuleError, 'failure_message_when_negated method called with ' \
                                           "#{args.size} arguments"
        end
      end

      # Expand method lookup to the application scope
      def method_missing(method_name, *args, &block)
        app && app.respond_to?(method_name) ? app.send(method_name, *args, &block) : super
      end

      def respond_to_missing?(method_name, include_private = false)
        super || app.respond_to?(method_name) || super
      end

      private

      attr_accessor :app, :value, :path_param, :rule_name
      attr_writer :rule_type

      # Helper method to perform validation of other rules inside validation block
      #
      #    validate do |params|
      #      # make use of built in validation rules in custom validations
      #      check(of_type(Integer), params[:id], :id)
      #      # or validate all parameters
      #      check(required(:id), params)
      #    end
      def check(rule, value, *args)
        if args.empty?
          ValidateMyRoutes::Validate::Rules.validate_all_params_rule! rule
        elsif args.size == 1
          ValidateMyRoutes::Validate::Rules.validate_single_param_rule! rule
        else
          raise Errors::MissusedRuleError, "check method called with #{args.size} arguments"
        end

        rule.validate!(app, value, path_param?, *args)
      end

      # Helper method to fail validation
      #
      #    validate do |params|
      #      fail_validation 'no!' if params.size > 1
      #    end
      def fail_validation(message, code = nil)
        code ||= failure_code(path_param?)
        raise Errors::ValidationError.new(message, code)
      end

      def path_param?
        path_param
      end
    end
  end
end
