module ValidateMyRoutes
  module Validate
    module Rules
      # Always successful validation rule
      module Anything
        ValidateMyRoutes::ValidationRules.def_validation_rule :anything do
          validate { |*_| true }
          description { 'anything' }
        end
      end
    end
  end
end
