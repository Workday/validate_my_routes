module ValidateMyRoutes
  # Route parameters validation extension
  # To start using it, the extension needs to be registered
  #
  #   register ValidateMyRoutes::Validatable
  #
  # Registering Validatable extension adds two conditions:
  #  - validate_all_params - a list of rules that need to be applied to all parameters together
  #  - validate_params - a hash with parameter names as keys and rules with extra information
  #      in values
  module Validatable
    class << self
      def registered(app)
        add_validate_params_condition_to app
        add_validate_all_params_condition_to app
      end

      private

      def add_validate_all_params_condition_to(app)
        app.set(:validate_all_params) do |*rules|
          condition do
            rules.all? { |rule| Validate.validate!(self, rule, params, false) }
          end
        end
      end

      # rubocop:disable AbcSize
      def add_validate_params_condition_to(app)
        app.set(:validate_params) do |*validations|
          condition do
            path_validations = validations.select { |_, rule| rule[:path_param] }
            query_validations = validations.reject { |_, rule| rule[:path_param] }

            [path_validations, query_validations].all? do |param_validations|
              param_validations.select { |_, rule| rule[:path_param] }.all? do |param_name, rule|
                value = params[param_name]
                Validate.validate!(self, rule[:rule], value, rule[:path_param], param_name)
              end
            end
          end
        end
      end
    end
    # rubocop:enable AbcSize

    # Define path parameter with validation for all routes (including nested routes)
    #
    #   param_validation :service_id, from_enum(%w[a b c])
    def param_validation(name, rule)
      Validate::Rules.validate_single_param_rule! rule
      (@param_validations ||= {})[name.to_sym] = rule
    end

    # Define all parameters validation for a single route
    #
    #   all_params_validation at_least_one_of(%i[version class status owner])
    #   get '/' do
    #     # params contain at least one of :version, :class, :status or :owner parameter
    #   end
    def all_params_validation(rule)
      Validate::Rules.validate_all_params_rule! rule
      (@all_params_validation ||= []) << rule
    end

    # Hook into .route Sinatra method to add validation for parameters
    def route(verb, route_pattern, conditions = {}, &block)
      route_path_parameters(route_pattern).each do |name|
        next unless param_validations.key? name

        rule = param_validations[name]
        # Add path parameter validation if it was specified
        (conditions[:validate_params] ||= {})[name] ||= { path_param: true, rule: rule }
      end

      # Add all params validation if it was specified
      conditions[:validate_all_params] = @all_params_validation if @all_params_validation
      @all_params_validation = nil # remove params validation as it is defined on per-route bases

      super(verb, route_pattern, conditions, &block)
    end

    def route_path_parameters(route_pattern)
      path_parameters = route_pattern.split('/').map do |part|
        part.start_with?(':') ? part[1..-1].to_sym : nil
      end

      path_parameters.flatten.compact.uniq.map(&:to_sym)
    end

    protected

    def param_validations
      parameters_defined_in_superclass = {}
      # For nested routes we need to look for defined parameters with validation in
      # superclass also.
      parameters_defined_in_superclass = superclass.param_validations \
        if superclass.respond_to?(:param_validations, true)
      parameters_defined_in_superclass.merge(@param_validations || {})
    end
  end
end
