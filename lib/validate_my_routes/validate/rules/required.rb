module ValidateMyRoutes
  module Validate
    module Rules
      # Validation rule that fails if parameter was not provided
      module Required
        ValidateMyRoutes::ValidationRules.def_all_params_validator :required do |parameter_name|
          validate { |params| params.key? parameter_name.to_s }
          description { "parameter <#{parameter_name}> is required" }
          failure_message { |_| "parameter <#{parameter_name}> was expected to be present" }
          failure_message_when_negated do |_|
            "parameter <#{parameter_name}> was expected not to be present"
          end
        end
      end
    end
  end
end
