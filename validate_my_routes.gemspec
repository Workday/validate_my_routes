lib = File.expand_path(File.join('..', 'lib'), __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'validate_my_routes/version'

Gem::Specification.new do |spec|
  spec.name          = 'validate_my_routes'
  spec.version       = ValidateMyRoutes::VERSION
  spec.authors       = ['Workday, Ltd.']
  spec.email         = ['prd.eng.os@workday.com']

  spec.summary       = 'A simple gem to validate Sinatra routes'
  spec.description   = 'ValidateMyRoutes provides a way to annotate Sinatra ' \
                       'routes and validate parameters before executing the route'
  spec.homepage      = 'https://github.com/Workday/validate_my_routes'
  spec.licenses      = ['MIT']

  spec.files         = Dir['lib/**/*.rb']
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler'
  spec.add_development_dependency 'rack-test'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rubocop'
  spec.add_development_dependency 'sinatra'
end
