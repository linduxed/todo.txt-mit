require_relative 'constants'
require_relative 'date_parser'

class BadDateError < StandardError; end
class BadTaskIDError < StandardError; end
class MITDateMissingError < StandardError; end
class MissingDateError < StandardError; end
class MissingTaskIDError < StandardError; end

class TodoFileMutator
  def initialize(todo_file_path)
    @todo_file_path = todo_file_path
  end

  def add_mit(date_string:, task:, include_creation_date:)
    date_string or raise(MissingDateError, 'date argument is missing.')
    parsed_date = DateParser.new(date_string).parse
    parsed_date or raise(BadDateError, "\"#{date_string}\" is not a valid date.")
    mit_date = "{#{parsed_date.strftime('%Y.%m.%d')}}"

    optional_creation_date = include_creation_date ? "#{Constants::TODAY} " : ''
    mit = "#{optional_creation_date}#{mit_date} #{task}"

    write_mit_at_end_of_todo_file(mit)

    id_of_added_todo = number_of_todos_in_todo_file
    "#{mit}\nTODO: #{id_of_added_todo} added."
  end

  def move_or_make_mit(task_id_string:, date_string:)
    all_tasks = File.readlines(@todo_file_path)
    if valid_task_id?(task_id_string, all_tasks)
      task_id = task_id_string.to_i
    else
      raise(BadTaskIDError, "No task for ID: #{task_id_string}")
    end

    date_string or raise(MissingDateError, 'date argument is missing.')
    parsed_date = DateParser.new(date_string).parse
    parsed_date or raise(BadDateError, "\"#{date_string}\" is not a valid date.")
    mit_date = "{#{parsed_date.strftime('%Y.%m.%d')}}"

    task = all_tasks[task_id - 1]
    changed_task =
      if already_has_mit_date?(task)
        change_mit_date(task, mit_date)
      else
        add_mit_date(task, mit_date)
      end
    all_tasks[task_id - 1] = changed_task
    overwrite_todo_file(all_tasks)

    formatted_date = DateFormatter.new(parsed_date).format(
      with_trailing_colon: false,
      capitalize: false,
    )
    "TODO: '#{task.chomp}' moved to #{formatted_date}"
  end

  def remove_mit_date(task_id_string:)
    task_id_string or raise(MissingTaskIDError, 'missing task ID.')

    all_tasks = File.readlines(@todo_file_path)
    if valid_task_id?(task_id_string, all_tasks)
      task_id = task_id_string.to_i
    else
      raise(BadTaskIDError, "No task for ID: #{task_id_string}")
    end

    task = all_tasks[task_id - 1]
    unless already_has_mit_date?(task)
      raise(MITDateMissingError, "Task #{task_id_string} is not a MIT: '#{task.chomp}'")
    end

    changed_task = task.gsub(/#{Constants::MIT_DATE_REGEX} /, '')
    all_tasks[task_id - 1] = changed_task
    overwrite_todo_file(all_tasks)

    "TODO: Removed MIT date from '#{changed_task.chomp}'"
  end

  def copy_mit(task_id_string:, date_string:, include_creation_date:)
    all_tasks = File.readlines(@todo_file_path)
    if valid_task_id?(task_id_string, all_tasks)
      task_id = task_id_string.to_i
    else
      raise(BadTaskIDError, "No task for ID: #{task_id_string}")
    end

    full_task = all_tasks[task_id - 1].chomp
    task_without_leading_priority_and_dates =
      strip_leading_priority_and_dates(full_task)

    add_mit(
      date_string: date_string,
      task: task_without_leading_priority_and_dates,
      include_creation_date: include_creation_date,
    )
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

  def valid_task_id?(task_id_string, tasks)
    id = task_id_string.to_i # Note: String#to_i on non-numbers returns 0.

    return false if id <= 0
    return false if tasks.count < id

    true
  end

  def add_mit_date(task, mit_date)
    priority_regex = /\([A-Z]\)/
    date_regex = /\d{4}-\d{2}-\d{2}/

    if task.start_with?('x ')
      task.gsub(
        /^x ((#{date_regex} ){0,2})(.+)$/,
        "x \\1#{mit_date} \\3"
      )
    else
      task.gsub(
        /^(#{priority_regex} )?(#{date_regex} )?(.+)$/,
        "\\1\\2#{mit_date} \\3"
      )
    end
  end

  def change_mit_date(task, mit_date)
    task.gsub(Constants::MIT_DATE_REGEX, mit_date)
  end

  def overwrite_todo_file(tasks)
    File.write(@todo_file_path, tasks.join)
  end

  def strip_leading_priority_and_dates(task)
    priority_regex = /\([A-Z]\)/
    date_regex = /\d{4}-\d{2}-\d{2}/

    task.gsub(
      /^(#{priority_regex} |x )?(#{date_regex} ){0,2}(#{Constants::MIT_DATE_REGEX} )?(.+)$/,
      '\5'
    )
  end
end
