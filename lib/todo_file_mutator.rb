require_relative 'constants'
require_relative 'date_parser'

class BadDateError < StandardError; end

class TodoFileMutator
  def initialize(todo_file_path)
    @todo_file_path = todo_file_path
  end

  def add_mit(date:, task:, include_creation_date:)
    parsed_date = DateParser.new(date).parse
    raise(BadDateError, "\"#{date}\" is not a valid date.") unless parsed_date
    mit_date = parsed_date.strftime('%Y.%m.%d')

    optional_creation_date =
      if include_creation_date
        "#{Constants::TODAY} "
      else
        ''
      end
    mit = "#{optional_creation_date}{#{mit_date}} #{task}"

    write_mit_at_end_of_todo_file(mit)

    "#{mit}\nTODO: #{number_of_todos_in_todo_file} added."
  end

  private

  def write_mit_at_end_of_todo_file(mit)
    File.open(@todo_file_path, 'a') { |file| file.puts(mit) }
  end

  def number_of_todos_in_todo_file
    File.foreach(@todo_file_path).reduce(0) { |count| count + 1 }
  end
end
