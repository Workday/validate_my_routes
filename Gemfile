source 'https://rubygems.org'

gemspec

# This is needed for ruby version older than 2.2.0 as bundler resolves Sinatra to the latest
# version with dependency on mustermann that works only with ruby version >= 2.2.0
gem 'sinatra', '< 2.0' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.2.0')
