class CLI
  def run
    case
    when usage_requested_from_todo_help?
      $stdout.puts usage_message
      exit 0
    when usage_requested?
      $stdout.puts usage_message
      exit 0
    when version_requested?
      $stdout.puts version_message
      exit 0
    when no_action_arguments?
      $stdout.puts all_mits_listing
      exit 0
    end
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

  def usage_requested?
    ARGV[1] == 'usage' ||
      ARGV[1] == '-h' ||
      ARGV[1] == '--help'
  end

  def version_requested?
    ARGV[1] == '-v' ||
      ARGV[1] == '--version'
  end

  def no_action_arguments?
    ARGV[2].nil?
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
