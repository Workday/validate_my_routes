module ValidateMyRoutes
  module Validate
    module Rules
      # Validation rules that designed to be used for validating all parameters
      # in the route.
      #
      # For example if we need to allow specifying "all" or "search" criteria,
      # but not both at the same time.
      module AllParameters
        ValidateMyRoutes::ValidationRules.def_all_params_validator :only_one_of do |names|
          raise Errors::MissusedRuleError, 'names must be an array' unless names.is_a? Array

          validate do |params|
            present_parameters_count = names.count { |name| params.key? name.to_s }
            present_parameters_count <= 1
          end

          description { "only one of <#{names.join(', ')}> parameters" }

          failure_message do |actual|
            "was expected to have only one of <#{names.join(', ')}> parameters, " \
            "but <#{actual.keys.join(', ')}> #{actual.size > 1 ? 'were' : 'was'} provided"
          end

          failure_message_when_negated do |actual|
            "was expected to have all of <#{names.join(', ')}> parameters, " \
            "but <#{actual.keys.join(', ')}> #{actual.size > 1 ? 'were' : 'was'} provided"
          end
        end

        ValidateMyRoutes::ValidationRules.def_all_params_validator :exactly_one_of do |names|
          raise Errors::MissusedRuleError, 'names must be an array' unless names.is_a? Array

          validate do |params|
            present_parameters_count = names.count { |name| params.key? name.to_s }
            present_parameters_count == 1
          end

          description { "exactly one of <#{names.join(', ')}> parameters" }

          failure_message do |actual|
            "was expected to have exactly one of <#{names.join(', ')}> parameters, " \
            "but <#{actual.keys.join(', ')}> #{actual.size > 1 ? 'were' : 'was'} provided"
          end

          failure_message_when_negated do |actual|
            "was expected to have none or more than one of <#{names.join(', ')}>, " \
            "but <#{actual.keys.join(', ')}> #{actual.size > 1 ? 'were' : 'was'} provided"
          end
        end

        ValidateMyRoutes::ValidationRules.def_all_params_validator :at_least_one_of do |names|
          raise Errors::MissusedRuleError, 'names must be an array' unless names.is_a? Array

          validate do |params|
            present_parameters_count = names.count { |name| params.key? name.to_s }
            present_parameters_count >= 1
          end

          description { "at least one of <#{names.join(', ')}> parameters" }

          failure_message do |actual|
            "was expected to have at least one of <#{names.join(', ')}> parameters, " \
            "but <#{actual.keys.join(', ')}> #{actual.size > 1 ? 'were' : 'was'} provided"
          end

          failure_message_when_negated do |actual|
            "was expected to have none of <#{names.join(', ')}>, " \
            "but <#{actual.keys.join(', ')}> #{actual.size > 1 ? 'were' : 'was'} provided"
          end
        end
      end
    end
  end
end
