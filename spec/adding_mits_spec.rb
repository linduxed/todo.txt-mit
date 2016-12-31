require 'spec_helper'

describe 'Adding MITs' do
  describe 'with the format `todo.sh mit YYYY.MM.DD "foobar"`' do
    context 'ENV["TODOTXT_DATE_ON_ADD"] is set' do
      specify 'a MIT with a creation date is added to the TODO_FILE' do
        fixed_time = '2016-12-01'
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF
        original_todo_count = various_todos.split("\n").count

        with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
          mit_date = '2016.12.05'
          env_extension.merge!('TODOTXT_DATE_ON_ADD' => '1')

          executable = Executable.run(
            "add #{mit_date} \"Run errand @work\"",
            env_extension: env_extension
          )

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).to include(
            /\A#{fixed_time} {#{mit_date}} Run errand @work\z/
          )
          expect(executable.lines).to include(
            "TODO: #{original_todo_count + 1} added."
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines.last).to match(
            /^#{fixed_time} {#{mit_date}} Run errand @work$/
          )
          expect(todo_file_lines.count).to eq(original_todo_count + 1)
        end
      end
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
end
