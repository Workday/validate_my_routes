require 'rspec/core/formatters'

##
# DocsFormatter outputs markdown file to create auto generated documentation from tests.
# It also can set example code by publishing custom notification :sample_code_added
#
# To use it for updating validation rules documentation, run:
#    bundle exec rspec spec/system/validate_my_routes/validation_rules_spec.rb \
#      --require ./spec/formatters/docs_formatter.rb \
#      --format=DocsFormatter \
#      > validation_rules.md
#
# RSpec Formatter protocol (copy from Github sources):
# * To start
#   * start(StartNotification)
# * Once per example group
#   * example_group_started(GroupNotification)
# * Once per example
#   * example_started(ExampleNotification)
# * One of these per example, depending on outcome
#   * example_passed(ExampleNotification)
#   * example_failed(FailedExampleNotification)
#   * example_pending(ExampleNotification)
# * Optionally at any time
#   * message(MessageNotification)
# * At the end of the suite
#   * stop(ExamplesNotification)
#   * start_dump(NullNotification)
#   * dump_pending(ExamplesNotification)
#   * dump_failures(ExamplesNotification)
#   * dump_summary(SummaryNotification)
#   * seed(SeedNotification)
#   * close(NullNotification)
class DocsFormatter
  NOTIFICATIONS = %i(sample_code_added example_started example_passed example_pending example_failed
                     example_group_started example_group_finished).freeze

  # This registers the notifications this formatter supports, and tells
  # us that this was written against the RSpec 3.x formatter API.
  RSpec::Core::Formatters.register self, *NOTIFICATIONS

  def initialize(output)
    @output = output
    @level = 0
    @header_level = 0
  end

  def sample_code_added(notification)
    initial_indentation = ' ' * notification.code[/\A */].size
    lines = notification.code.split("\n").map { |line| line.gsub(/^#{initial_indentation}/, '') }
    code = lines.join("\n")
    @output << "```ruby\n#{code}\n```\n\n"
  end

  def example_group_started(notification)
    is_header = header?(notification.group.location)
    @level += 1
    @header_level += 1 if is_header
    @output << format_indented_line(is_header) { notification.group.description }
  end

  def example_group_finished(notification)
    is_header = header?(notification.group.location)
    @output << "\n" if is_header
    @level -= 1
    @header_level -= 1 if is_header
  end

  def example_started(_)
    @level += 1
  end

  def example_passed(notification)
    @output << format_indented_line { notification.example.description }
    @level -= 1
  end

  def example_pending(notification)
    @output << format_indented_line { "example pending: **#{notification.example.description}**" }
    @level -= 1
  end

  def example_failed(notification)
    @output << format_indented_line { "example failed: **#{notification.example.description}**:" }
    @output << "\n```ruby\n#{notification.exception}"
    @output << "\n#{notification.formatted_backtrace.join("\n")}\n```\n"
    @level -= 1
  end

  private

  def header?(location)
    file, line = location.split(':')
    File.readlines(file)[line.to_i - 1].strip.start_with? 'describe'
  end

  def format_indented_line(is_header = false)
    prefix = is_header ? '#' * @level : '  ' * (@level - @header_level - 1) + '*'
    postfix = is_header ? "\n\n" : "\n"
    "#{prefix} #{yield}#{postfix}"
  end
end
