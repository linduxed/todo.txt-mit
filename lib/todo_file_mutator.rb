require_relative 'constants'
require_relative 'date_parser'

class BadDateError < StandardError; end
class BadTaskIDError < StandardError; end

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

  def make_mit(task_id:, date:)
    all_tasks = File.readlines(@todo_file_path)
    task = maybe_find_task(task_id, all_tasks)
    raise(BadTaskIDError, "No task for ID: #{task_id}") unless task

    parsed_date = DateParser.new(date).parse
    raise(BadDateError, "\"#{date}\" is not a valid date.") unless parsed_date
    mit_date = parsed_date.strftime('%Y.%m.%d')

    task_with_added_mit_date = add_mit_date(task, mit_date)
    all_tasks[task_id.to_i - 1] = task_with_added_mit_date
    overwrite_todo_file(all_tasks)

    "TODO: '#{task.chomp}' moved to #{parsed_date}"
  end

  private

  def write_mit_at_end_of_todo_file(mit)
    File.open(@todo_file_path, 'a') { |file| file.puts(mit) }
  end

  def number_of_todos_in_todo_file
    File.foreach(@todo_file_path).reduce(0) { |count| count + 1 }
  end

  def already_has_mit_date?(task)
    task.match(Constants::MIT_DATE_REGEX)
  end

  def maybe_find_task(task_id, tasks)
    id = task_id.to_i # Note: String#to_i on non-numbers returns 0.

    return nil if id <= 0
    return nil if tasks.count < id

    tasks[id - 1]
  end

  def add_mit_date(task, mit_date)
    priority_regex = /\([A-Z]\)/
    date_regex = /\d{4}-\d{2}-\d{2}/

    if task.start_with?('x ')
      task.gsub(
        /^x ((#{date_regex} ){0,2})(.+)$/,
        "x \\1{#{mit_date}} \\3"
      )
    else
      task.gsub(
        /^(#{priority_regex} )?(#{date_regex} )?(.+)$/,
        "\\1\\2{#{mit_date}} \\3"
      )
    end
  end

  def overwrite_todo_file(tasks)
    File.write(@todo_file_path, tasks.join)
  end
end
