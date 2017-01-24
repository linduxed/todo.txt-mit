require 'spec_helper'

describe 'Changing the MIT date of a TODO' do
  describe 'with the format `todo.sh mit mv 123 YYYY.MM.DD`' do
    specify 'TODO has its MIT date replaced' do
      fixed_time = '2016-12-01'
      tomorrow_in_mit_form = '2016.12.02'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
        executable = Executable.run(
          "mv 4 #{tomorrow_in_mit_form}",
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /TODO:.+Play guitar.+moved to.+2016.12.02/
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines[3]).to match(
          /^\(B\) \{#{tomorrow_in_mit_form}\} Play guitar @personal$/
        )
      end
    end
  end

  describe 'with the format `todo.sh mit mv 123 WEEKDAY`' do
    specify 'TODO has its MIT date replaced' do
      fixed_time = '2016-12-01'
      saturday_in_mit_form = '2016.12.03'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        (C) 2016-11-26 Throw out trash @personal
      EOF

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
        executable = Executable.run(
          'mv 4 saturday',
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /TODO:.+Play guitar.+moved to.+2016.12.03/
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines[3]).to match(
          /^\(B\) \{#{saturday_in_mit_form}\} Play guitar @personal$/
        )
      end
    end
  end

  context 'TODO is completed' do
    specify 'TODO has its MIT date replaced' do
      fixed_time = '2016-12-01'
      tomorrow_in_mit_form = '2016.12.02'
      various_todos = <<-EOF
        (A) Important email +read
        x 2016-11-29 2016-10-23 {2016.11.29} That long article @personal +read
        (B) {2016.11.29} Play guitar @personal
        (C) 2016-11-26 Throw out trash @personal
      EOF

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
        executable = Executable.run(
          'mv 2 tomorrow',
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /TODO:.+That long article.+moved to.+2016.12.02/
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines[1]).to match(
          /^x 2016-11-29 2016-10-23 \{#{tomorrow_in_mit_form}\} That long article @personal \+read$/
        )
      end
    end
  end
end
