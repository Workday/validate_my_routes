module ValidateMyRoutes
  module Validate
    module Rules
      # Always successful validation rule
      module Enum
        ValidateMyRoutes::ValidationRules.def_single_param_validator :from_enum do |values|
          unless values.respond_to? :include?
            raise Errors::MissusedRuleError, 'from_enum rule requires #include? method on ' \
                                             'expectation'
          end
          validate { |actual, _| values.include? actual }
          failure_message do |actual, name|
            "parameter <#{name}> was expected to have one of following values: " \
            "<#{values.join ', '}>, but was <#{actual}>"
          end
          description { "of enum type with values: #{values.join(', ')}" }
        end
      end
    end
  end
end
