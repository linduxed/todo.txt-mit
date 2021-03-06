require_relative 'constants'
require_relative 'mit'

class TodoFileParser
  TODOWithNumber = Struct.new(:line, :number)

  def initialize(todo_file_path)
    @todo_file_path = todo_file_path
  end

  def mits
    todo_lines = File.readlines(@todo_file_path)
    chomped_lines = todo_lines.map(&:chomp)

    all_todos = chomped_lines.map.with_index do |line, index|
      # todo.sh uses the line numbers of the tasks as their IDs.
      # The IDs are 1-indexed, which is why `index` is incremented by 1.
      TODOWithNumber.new(line, index + 1)
    end

    not_completed_todos = all_todos.reject do |todo|
      todo.line.start_with?('x ')
    end

    not_completed_todos.
      select { |todo| todo.line.match(Constants::MIT_DATE_REGEX) }.
      map { |todo| MIT.new(todo.line, todo.number) }
  end
end
