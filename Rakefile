require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new

DOC_DIR = 'docs'.freeze

desc "Generate documentation from system tests\n\n"
task :generate_documentation do
  puts 'Generating documentation from system tests'

  gem_dir = File.dirname(__FILE__)
  formatter_path = File.join(gem_dir, 'spec', 'formatters', 'docs_formatter.rb')
  test_files = File.join(gem_dir, 'spec', 'system', 'validate_my_routes', '*.rb')

  Dir.glob(test_files).each do |file|
    out_file_name = (File.basename file).split(/[_\.]/)[0..-3].join('_')
    out_file = File.join(gem_dir, DOC_DIR, "#{out_file_name}.md")
    `bundle exec rspec #{file} --require=#{formatter_path} --format=DocsFormatter > #{out_file}`
  end

  puts "Documentation generated in #{DOC_DIR}"
end

task default: %i[rubocop spec]
