module ValidateMyRoutes
  module Validate
    module Rules
      # List of comparison rules
      module Comparable
        VR = ValidateMyRoutes::ValidationRules

        VR.def_single_param_validator :eql do |expected|
          validate { |actual, _| actual == expected }
          description { "equal to <#{expected}>" }
          failure_message do |actual, name|
            "was expected #{name} parameter to equal <#{expected}>, but was <#{actual}>"
          end
          failure_message_when_negated do |actual, name|
            "was expected #{name} parameter to not equal <#{expected}>, but was <#{actual}>"
          end
        end

        VR.def_single_param_validator :greater_than do |expected|
          validate { |actual, _| actual > expected }
          description { "greater than <#{expected}>" }
          failure_message do |actual, name|
            "was expected #{name} parameter to be greater than <#{expected}>, but was <#{actual}>"
          end
          failure_message_when_negated do |actual, name|
            "was expected #{name} parameter to be less than or equal to <#{expected}>, " \
            "but was <#{actual}>"
          end
        end

        VR.def_single_param_validator :greater_than_or_equal_to do |expected|
          validate { |actual, _| actual >= expected }
          description { "greater than or equal to <#{expected}>" }
          failure_message do |actual, name|
            "was expected #{name} parameter to be greater than or equal to <#{expected}>, " \
            "but was <#{actual}>"
          end
          failure_message_when_negated do |actual, name|
            "was expected #{name} parameter to be less than <#{expected}>, but was <#{actual}>"
          end
        end

        VR.def_single_param_validator :less_than do |expected|
          validate { |actual, _| actual < expected }
          description { "less than <#{expected}>" }
          failure_message do |actual, name|
            "was expected #{name} parameter to be less than <#{expected}>, but was <#{actual}>"
          end
          failure_message_when_negated do |actual, name|
            "was expected #{name} parameter to be greater than or equal to <#{expected}>, " \
            "but was <#{actual}>"
          end
        end

        VR.def_single_param_validator :less_than_or_equal_to do |expected|
          validate { |actual, _| actual <= expected }
          description { "less than or equal to <#{expected}>" }
          failure_message do |actual, name|
            "was expected #{name} parameter to be less than or equal to <#{expected}>, " \
            "but was <#{actual}>"
          end
          failure_message_when_negated do |actual, name|
            "was expected #{name} parameter to be greater than <#{expected}>, but was <#{actual}>"
          end
        end

        VR.def_single_param_validator :between do |min, max|
          validate { |actual, _| actual >= min && actual <= max }
          description { "between <#{min}> and <#{max}>" }
          failure_message do |actual, name|
            "was expected #{name} parameter to be between <#{min}> and <#{max}>, " \
            "but was <#{actual}>"
          end
          failure_message_when_negated do |actual, name|
            "was expected #{name} parameter to be less than <#{min}> or greater than <#{max}>, " \
            "but was <#{actual}>"
          end
        end
      end
    end
  end
end
