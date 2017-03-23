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
          /TODO:.+Play guitar.+moved to tomorrow.*/
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
          /TODO:.+Play guitar.+moved to Saturday.*/
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines[3]).to match(
          /^\(B\) \{#{saturday_in_mit_form}\} Play guitar @personal$/
        )
      end
    end
  end

  describe 'with the format `todo.sh mit mv 123 RELATIVE_DATE' do
    {
      '1d' => '2016.12.02',
      '3d' => '2016.12.04',
      '10d' => '2016.12.11',
      '40d' => '2017.01.10',
      '1w' => '2016.12.08',
      '5w' => '2017.01.05',
      '1m' => '2017.01.01',
      '3m' => '2017.03.01',
    }.each do |relative_date, mit_date|
      specify "a MIT is moved to RELATIVE_DATE \"#{relative_date}\"" do
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF

        with_fixed_time_and_todo_file('2016-12-01', various_todos) do |todo_file, env_extension|
          executable = Executable.run(
            "mv 4 #{relative_date}",
            env_extension: env_extension
          )

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).to include(/TODO:.+Play guitar.+moved to .+/)
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines[3]).to match(
            /^\(B\) {#{mit_date}} Play guitar @personal$/
          )
        end
      end
    end
  end

  context 'no date is provided' do
    specify 'an error is printed' do
      fixed_time = '2016-12-01'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |_, env_extension|
        executable = Executable.run('mv 2', env_extension: env_extension)

        expect(executable.exit_code).not_to eq(0)
        expect(executable.error).to match(/date.+missing/)
      end
    end
  end

  describe 'with the format `todo.sh mit mv 123 FREEFORM_DATE' do
    {
      '2010/03/22' => '2010.03.22',
      '22/03/2010' => '2010.03.22',
      '22-03-2010' => '2010.03.22',
    }.each do |freeform_date, mit_date|
      specify "a MIT is moved to FREEFORM_DATE \"#{freeform_date}\"" do
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF

        with_fixed_time_and_todo_file('2016-12-01', various_todos) do |todo_file, env_extension|
          executable = Executable.run(
            "mv 4 '#{freeform_date}'",
            env_extension: env_extension
          )

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).to include(/TODO:.+Play guitar.+moved to .+/)
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines[3]).to match(
            /^\(B\) {#{mit_date}} Play guitar @personal$/
          )
        end
      end
    end
  end

  context 'a bad date is provided' do
    specify 'an error is printed' do
      fixed_time = '2016-12-01'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |_, env_extension|
        executable = Executable.run('mv 2 foobar', env_extension: env_extension)

        expect(executable.exit_code).not_to eq(0)
        expect(executable.error).to match(/foobar.+valid date/)
      end
    end
  end

  context 'a bad task ID is provided' do
    specify 'an error is printed' do
      fixed_time = '2016-12-01'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |_, env_extension|
        executable = Executable.run('mv 10 today', env_extension: env_extension)

        expect(executable.exit_code).not_to eq(0)
        expect(executable.error).to match(/ID.+10/)
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
