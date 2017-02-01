require 'spec_helper'

describe 'Adding a MIT date to a TODO' do
  describe 'with the format `todo.sh mit mv 123 YYYY.MM.DD`' do
    context 'TODO has a creation date' do
      context 'TODO does not have a priority' do
        specify 'TODO gets a MIT date after the creation date' do
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
              "mv 5 #{tomorrow_in_mit_form}",
              env_extension: env_extension
            )

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(
              /TODO:.+Make phone call.+moved to tomorrow.*/
            )
            todo_file_lines = File.readlines(todo_file.path)
            expect(todo_file_lines[4]).to match(
              /^2016-11-26 \{#{tomorrow_in_mit_form}\} Make phone call @personal$/
            )
          end
        end
      end

      context 'TODO has a priority' do
        specify 'TODO gets a MIT date after the creation date' do
          fixed_time = '2016-12-01'
          tomorrow_in_mit_form = '2016.12.02'
          various_todos = <<-EOF
            (A) Important email +read
            That long article @personal +read
            x 2016-11-30 2016-11-30 Buy milk @personal
            (B) {2016.11.29} Play guitar @personal
            (C) 2016-11-26 Throw out trash @personal
          EOF

          with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
            executable = Executable.run(
              "mv 5 #{tomorrow_in_mit_form}",
              env_extension: env_extension
            )

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(
              /TODO:.+Throw out trash.+moved to tomorrow.*/
            )
            todo_file_lines = File.readlines(todo_file.path)
            expect(todo_file_lines[4]).to match(
              /^\(C\) 2016-11-26 \{#{tomorrow_in_mit_form}\} Throw out trash @personal$/
            )
          end
        end
      end
    end

    context 'TODO does not have a creation date' do
      context 'TODO does not have a priority' do
        specify 'TODO gets a MIT date at the start of the line' do
          fixed_time = '2016-12-01'
          tomorrow_in_mit_form = '2016.12.02'
          various_todos = <<-EOF
            (A) Important email +read
            That long article @personal +read
            x 2016-11-30 2016-11-30 Buy milk @personal
            (B) {2016.11.29} Play guitar @personal
            (C) 2016-11-26 Throw out trash @personal
          EOF

          with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
            executable = Executable.run(
              "mv 2 #{tomorrow_in_mit_form}",
              env_extension: env_extension
            )

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(
              /TODO:.+That long article.+moved to tomorrow.+/
            )
            todo_file_lines = File.readlines(todo_file.path)
            expect(todo_file_lines[1]).to match(
              /^\{#{tomorrow_in_mit_form}\} That long article @personal \+read$/
            )
          end
        end
      end

      context 'TODO has a priority' do
        specify 'TODO gets a MIT date after the priority' do
          fixed_time = '2016-12-01'
          tomorrow_in_mit_form = '2016.12.02'
          various_todos = <<-EOF
            (A) Important email +read
            That long article @personal +read
            x 2016-11-30 2016-11-30 Buy milk @personal
            (B) {2016.11.29} Play guitar @personal
            (C) 2016-11-26 Throw out trash @personal
          EOF

          with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
            executable = Executable.run(
              "mv 1 #{tomorrow_in_mit_form}",
              env_extension: env_extension
            )

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(
              /TODO:.+Important email.+moved to tomorrow.*/
            )
            todo_file_lines = File.readlines(todo_file.path)
            expect(todo_file_lines[0]).to match(
              /^\(A\) \{#{tomorrow_in_mit_form}\} Important email \+read$/
            )
          end
        end
      end
    end
  end

  describe 'with the format `todo.sh mit mv 123 WEEKDAY`' do
    specify 'TODO gets a MIT date for WEEKDAY' do
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
          'mv 2 saturday',
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /TODO:.+That long article.+moved to Saturday.*/
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines[1]).to match(
          /^\{#{saturday_in_mit_form}\} That long article @personal \+read$/
        )
      end
    end
  end

  context 'TODO is completed' do
    context 'TODO has neither creation date nor completion date' do
      specify 'completed TODO gets a MIT date after leading "x"' do
        fixed_time = '2016-12-01'
        tomorrow_in_mit_form = '2016.12.02'
        various_todos = <<-EOF
          (A) Important email +read
          x That long article @personal +read
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
            /TODO:.+That long article.+moved to tomorrow.*/
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines[1]).to match(
            /^x \{#{tomorrow_in_mit_form}\} That long article @personal \+read$/
          )
        end
      end
    end

    context 'TODO has completion date' do
      specify 'completed TODO gets a MIT date after leading "x" and date' do
        fixed_time = '2016-12-01'
        tomorrow_in_mit_form = '2016.12.02'
        various_todos = <<-EOF
          (A) Important email +read
          x 2016-11-29 That long article @personal +read
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
            /TODO:.+That long article.+moved to tomorrow.*/
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines[1]).to match(
            /^x 2016-11-29 \{#{tomorrow_in_mit_form}\} That long article @personal \+read$/
          )
        end
      end
    end

    context 'TODO has completion and creation date' do
      specify 'completed TODO gets a MIT date after leading "x" and dates' do
        fixed_time = '2016-12-01'
        tomorrow_in_mit_form = '2016.12.02'
        various_todos = <<-EOF
          (A) Important email +read
          x 2016-11-29 2016-10-23 That long article @personal +read
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
            /TODO:.+That long article.+moved to tomorrow.*/
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines[1]).to match(
            /^x 2016-11-29 2016-10-23 \{#{tomorrow_in_mit_form}\} That long article @personal \+read$/
          )
        end
      end
    end
  end
end
