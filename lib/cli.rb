require_relative 'todo_file_mutator'
require_relative 'todo_file_parser'
require_relative 'mit_list_formatter'

class CLI
  class BadActionError < StandardError; end

  EX_USAGE = 64

  def run
    output =
      case
      when usage_requested_from_todo_help?
        usage_message
      when %w(usage -h --help).include?(ARGV[1])
        usage_message
      when %w(-v --version).include?(ARGV[1])
        version_message
      when ARGV[1].nil?
        MITListPrinter.new(ENV['TODO_FILE']).all_mits
      when ARGV[1].match(/@\w+/)
        MITListPrinter.new(ENV['TODO_FILE']).mits_with_context(
          context: ARGV[1]
        )
      when ARGV[1] == 'not' && ARGV[2].match(/@\w+/)
        MITListPrinter.new(ENV['TODO_FILE']).mits_without_context(
          context: ARGV[2]
        )
      when ARGV[1] == 'mv'
        TodoFileMutator.new(ENV['TODO_FILE']).move_or_make_mit(
          task_id_string: ARGV[2],
          date_string: ARGV[3],
        )
      when ARGV[1] == 'rm'
        TodoFileMutator.new(ENV['TODO_FILE']).remove_mit_date(
          task_id_string: ARGV[2],
        )
      when !ARGV[1].nil? && !ARGV[2].nil?
        TodoFileMutator.new(ENV['TODO_FILE']).add_mit(
          date_string: ARGV[1],
          task: ARGV[2],
          include_creation_date: ENV['TODOTXT_DATE_ON_ADD'],
        )
      else
        fail BadActionError
      end

    $stdout.puts output
    exit 0
  rescue BadDateError, BadTaskIDError, MITDateMissingError, MissingDateError => e
    $stderr.puts "MIT: #{e.message}"
    exit EX_USAGE
  rescue BadActionError
    $stderr.puts usage_message
    exit EX_USAGE
  end

  private

  def usage_requested_from_todo_help?
    # Normally the add-on will be invoked as a subcommand (like
    # `todo.sh mit foo`), meaning that the actual mit-action, along with its
    # various arguments, will be placed in ARGV[1] and higher.
    #
    # The only exception to this case is when the add-on is invoked through
    # `todo.sh help`. This command will iterate through all available add-ons
    # and invoke them like `mit usage`, meaning that the action will be present
    # in ARGV[0].

    ARGV[0] == 'usage'
  end

  def usage_message
    usage_message = <<-EOF
      Most Important Tasks (MIT):
        Displays Most Important Tasks (MIT) in todo.txt file, adds new ones or
        turns MIT tasks into standard ones.

        mit [-h|--help|-v|--version] [date|day|relativedate task] [rm ID]
          [not @context|@context] [mv ID DATE|DAY|RELATIVEDATE]

        -h, --help      Displays help message.
        -v, --version   Displays version information.

        mit
          List all MITs with default formatting.

        mit rm ID
          Convert the MIT identified by ID to a standard task.

        mit not @context|@context
          Displays all MIT's not in or in specified context.

        mit DATE|DAY|RELATIVEDATE task
          DATE must be in the format of YYYY.MM.DD.
          DAY can be full or short day names, today or tomorrow.
          RELATIVEDATE is defined as an integer, followed by one of the letters
          "d", "w" or "m" (days, weeks and months).

        mit mv ID DATE|DAY|RELATIVEDATE
          Move the MIT identified by ID to a new day.
          DATE must be in the format of YYYY.MM.DD.
          DAY can be full or short day names, today or tomorrow.
          RELATIVEDATE is defined as an integer, followed by one of the letters
          "d", "w" or "m" (days, weeks and months).
    EOF

    # Remove leading indentation
    usage_message.gsub(/^#{usage_message.scan(/^[ \t]*(?=\S)/).min}/, '')
  end

  def version_message
    "mit (ruby) #{Constants::VERSION}"
  end
end
