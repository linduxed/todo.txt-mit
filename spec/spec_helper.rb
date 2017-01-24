require 'open3'
require 'tempfile'

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
end

class Executable
  def self.run(
    args_string = '',
    prepend_program_name_to_args: true,
    env_extension: {}
  )
    new(args_string, prepend_program_name_to_args, env_extension).tap(&:run)
  end

  def initialize(args_string, prepend_program_name_to_args, env_extension)
    @args_string = args_string
    @prepend_program_name_to_args = prepend_program_name_to_args
    @env_extension = env_extension
  end

  def run
    old_env = ENV.to_h
    ENV.update(@env_extension)

    if @prepend_program_name_to_args
      @args_string = @args_string.prepend('mit ')
    end

    _, @stdout, @stderr, @wait_thr = Open3.popen3(
      "#{binary_location} #{@args_string}"
    )

    ENV.replace(old_env)
  end

  def lines
    @lines ||= @stdout.readlines.map(&:chomp)
  end

  def error
    @error ||= @stderr.read
  end

  def exit_code
    @wait_thr.value.exitstatus
  end

  private

  def binary_location
    File.expand_path('../../bin/mit', __FILE__)
  end
end

def with_fixed_time_and_todo_file(date_string, todos)
  todo_file = Tempfile.new('todo.txt')
  todos.gsub!(/^\s+/, '')

  todo_file.write(todos)
  todo_file.close

  env_extension = {
    'TODO_FILE' => todo_file.path,
    'FIXED_DATE' => date_string,
  }

  yield(todo_file, env_extension)

  todo_file.delete
end
