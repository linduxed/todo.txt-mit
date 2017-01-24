require_relative 'todo_file_mutator'
require_relative 'todo_file_parser'
require_relative 'mit_list_formatter'

class CLI
  class BadActionError < StandardError; end

  EX_USAGE = 64

  def run
    case
    when usage_requested_from_todo_help?
      $stdout.puts usage_message
      exit 0
    when %w(usage -h --help).include?(ARGV[1])
      $stdout.puts usage_message
      exit 0
    when %w(-v --version).include?(ARGV[1])
      $stdout.puts version_message
      exit 0
    when ARGV[1].nil?
      $stdout.puts all_mits_listing
      exit 0
    when ARGV[1] == 'add'
      message = TodoFileMutator.new(ENV['TODO_FILE']).add_mit(
        date: ARGV[2],
        task: ARGV[3],
        include_creation_date: ENV['TODOTXT_DATE_ON_ADD'],
      )
      $stdout.puts message
      exit 0
    when ARGV[1] == 'mv'
      message = TodoFileMutator.new(ENV['TODO_FILE']).move_or_make_mit(
        task_id: ARGV[2],
        date: ARGV[3],
      )
      $stdout.puts message
      exit 0
    else
      fail BadActionError
    end
  rescue BadDateError, BadTaskIDError => e
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
        Displays Most Important Tasks (MIT) in todo.txt file, or adds new ones.

        mit [-h|--help|-v|--version]

        -h, --help      Displays help message.
        -v, --version   Displays version information.

        mit
          List all MITs with default formatting.
    EOF

    # Remove leading indentation
    usage_message.gsub(/^#{usage_message.scan(/^[ \t]*(?=\S)/).min}/, '')
  end

  def version_message
    "mit (ruby) #{Constants::VERSION}"
  end

  def all_mits_listing
    mits = TodoFileParser.new(ENV['TODO_FILE']).mits

    if mits.empty?
      'No MITs found.'
    else
      MITListFormatter.new(mits).grouped_by_date
    end
  end
end
