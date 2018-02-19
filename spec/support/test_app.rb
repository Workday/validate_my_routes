require 'sinatra/base'
require 'validate_my_routes'
require 'time'

# Test Sinatra application that can be amended
class TestApp < Sinatra::Base
  class << self
    def amend(code, *rest)
      RSpec.configuration.reporter.publish(:sample_code_added, code: code)
      class_eval(code, *rest)
    end
  end
end
