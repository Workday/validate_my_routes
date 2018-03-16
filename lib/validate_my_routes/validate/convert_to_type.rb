require 'time'

module ValidateMyRoutes
  module Validate
    # ConvertToType module provides single method convert_to_type to convert value into type
    # to_type. Conversion can fail with InvalidTypeError.
    module ConvertToType
      class << self
        Boolean         = :Boolean # rubocop:disable Naming/ConstantName
        SIMPLE_TYPES    = [Float, String, Date, Time, DateTime, Integer].freeze
        COMPOSITE_TYPES = [Array, Hash].freeze
        BOOLEAN_TYPES   = [Boolean, TrueClass, FalseClass].freeze

        def convert_to_type(value, to_type)
          return value if already_of_type?(value, to_type)

          if SIMPLE_TYPES.include?(to_type)
            parse_simple_type(value, to_type)
          elsif COMPOSITE_TYPES.include?(to_type)
            parse_composite_type(value, to_type)
          elsif BOOLEAN_TYPES.include?(to_type)
            parse_boolean(value)
          else
            raise_unknown_type(to_type)
          end
        rescue ArgumentError
          raise_with_invalid_type(value, to_type)
        end

        private

        def already_of_type?(value, typ)
          (typ.is_a?(Class) || typ.is_a?(Module)) && value.is_a?(typ)
        end

        def parse_simple_type(value, to_type)
          if to_type == Integer
            Integer(value)
          elsif [Float, String].include?(to_type)
            Kernel.send(to_type.to_s.to_sym, value)
          elsif to_type.respond_to? :parse
            to_type.parse(value)
          else
            raise_unknown_type(to_type)
          end
        end

        def parse_composite_type(value, to_type)
          if to_type == Array
            value.split(',')
          elsif to_type == Hash
            Hash[value.split(',').map { |item| item.split(':') }]
          else
            raise_unknown_type(to_type)
          end
        end

        def parse_boolean(value)
          if value.to_s.casecmp('false').zero?
            false
          elsif value.to_s.casecmp('true').zero?
            true
          else
            raise_with_invalid_type(value, Boolean)
          end
        end

        def raise_with_invalid_type(value, type)
          raise ValidateMyRoutes::Errors::InvalidTypeError,
                "'#{value}' is not a valid '#{type}'"
        end

        def raise_unknown_type(type)
          raise ValidateMyRoutes::Errors::InvalidTypeError,
                "don't know how to convert type '#{type}'"
        end
      end
    end
  end
end
