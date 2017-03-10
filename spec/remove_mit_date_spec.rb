require 'spec_helper'

describe 'Remove MIT date from a TODO' do
  describe 'with the format `todo.sh mit rm 123' do
    context 'TODO has no MIT date' do
      specify 'an error message is printed' do
        fixed_time = '2016-12-01'
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF

        with_fixed_time_and_todo_file(fixed_time, various_todos) do |_, env_extension|
          executable = Executable.run('rm 2', env_extension: env_extension)

          expect(executable.exit_code).not_to eq(0)
          expect(executable.error).to match(/2.+That long article/)
        end
      end
    end

    context 'no task ID is provided' do
      specify 'an error message is printed' do
        single_todo = <<-EOF
          (A) Important email +read
        EOF

        with_fixed_time_and_todo_file('2016-12-01', single_todo) do |_, env_extension|
          executable = Executable.run('rm', env_extension: env_extension)

          expect(executable.exit_code).not_to eq(0)
          expect(executable.error).to match(/missing.+ID/)
        end
      end
    end

    context 'bad task ID is provided' do
      specify 'an error message is printed' do
        single_todo = <<-EOF
          (A) Important email +read
        EOF

        with_fixed_time_and_todo_file('2016-12-01', single_todo) do |_, env_extension|
          executable = Executable.run('rm 2', env_extension: env_extension)

          expect(executable.exit_code).not_to eq(0)
          expect(executable.error).to match(/ID.+2/)
        end
      end
    end

    context 'TODO has a MIT date' do
      specify 'TODO has its MIT date removed' do
        fixed_time = '2016-12-01'
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF

        with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
          executable = Executable.run('rm 4', env_extension: env_extension)

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).to include(
            /TODO:.+Play guitar/
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines[3]).to match("(B) Play guitar @personal\n")
        end
      end
    end

    context 'TODO is completed' do
      specify 'TODO has its MIT date replaced' do
        fixed_time = '2016-12-01'
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 {2016.11.30} Buy milk @personal
          (B) Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF

        with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
          executable = Executable.run('rm 3', env_extension: env_extension)

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).to include(
            /TODO:.+Buy milk @personal/
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines[2]).to match(
            "x 2016-11-30 2016-11-30 Buy milk @personal\n"
          )
        end
      end
    end
  end
end
