require 'spec_helper'

describe 'Copying MITs' do
  describe 'with the format `todo.sh mit cp 123 YYYY.MM.DD' do
    specify 'a MIT is added for the specified date' do
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF
      original_todo_count = various_todos.split("\n").count

      with_fixed_time_and_todo_file('2016-12-01', various_todos) do |todo_file, env_extension|
        mit_date = '2016.12.05'

        executable = Executable.run(
          "cp 4 #{mit_date}",
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /\A{#{mit_date}} Play guitar @personal\z/
        )
        expect(executable.lines).to include(
          "TODO: #{original_todo_count + 1} added."
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines.last).to match(
          /^{#{mit_date}} Play guitar @personal$/,
        )
        expect(todo_file_lines).to include(
          /^\(B\) {2016\.11\.29} Play guitar @personal$/,
        )
        expect(todo_file_lines.count).to eq(original_todo_count + 1)
      end
    end
  end

  describe 'with the format `todo.sh cp 123 DAY' do
    specify 'a MIT is added for the DAY "today"' do
      fixed_time = '2016-12-01'
      fixed_time_in_mit_form = '2016.12.01'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF
      original_todo_count = various_todos.split("\n").count

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
        executable = Executable.run(
          "cp 4 today",
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /\A{#{fixed_time_in_mit_form}} Play guitar @personal\z/
        )
        expect(executable.lines).to include(
          "TODO: #{original_todo_count + 1} added."
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines.last).to match(
          /^{#{fixed_time_in_mit_form}} Play guitar @personal$/,
        )
        expect(todo_file_lines).to include(
          /^\(B\) {2016\.11\.29} Play guitar @personal$/,
        )
        expect(todo_file_lines.count).to eq(original_todo_count + 1)
      end
    end

    specify 'a MIT is added for the DAY "tomorrow"' do
      fixed_time = '2016-12-01'
      tomorrow_in_mit_form = '2016.12.02'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF
      original_todo_count = various_todos.split("\n").count

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
        executable = Executable.run(
          "cp 4 tomorrow",
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /\A{#{tomorrow_in_mit_form}} Play guitar @personal\z/
        )
        expect(executable.lines).to include(
          "TODO: #{original_todo_count + 1} added."
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines.last).to match(
          /^{#{tomorrow_in_mit_form}} Play guitar @personal$/,
        )
        expect(todo_file_lines).to include(
          /^\(B\) {2016\.11\.29} Play guitar @personal$/,
        )
        expect(todo_file_lines.count).to eq(original_todo_count + 1)
      end
    end

    describe 'weekdays' do
      fixed_time = '2016-12-01'
      {
        'monday' => '2016.12.05',
        'tuesday' => '2016.12.06',
        'wednesday' => '2016.12.07',
        'thursday' => '2016.12.08',
        'friday' => '2016.12.02',
        'saturday' => '2016.12.03',
        'sunday' => '2016.12.04',
        'mon' => '2016.12.05',
        'tue' => '2016.12.06',
        'wed' => '2016.12.07',
        'thu' => '2016.12.08',
        'fri' => '2016.12.02',
        'sat' => '2016.12.03',
        'sun' => '2016.12.04',
      }.each do |weekday, mit_date|
        specify "a MIT is added for the WEEKDAY \"#{weekday}\"" do
          various_todos = <<-EOF
            (A) Important email +read
            That long article @personal +read
            x 2016-11-30 2016-11-30 Buy milk @personal
            (B) {2016.11.29} Play guitar @personal
            2016-11-26 Make phone call @personal
          EOF
          original_todo_count = various_todos.split("\n").count

          with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
            executable = Executable.run(
              "cp 4 #{weekday}",
              env_extension: env_extension
            )

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(
              /\A{#{mit_date}} Play guitar @personal\z/
            )
            expect(executable.lines).to include(
              "TODO: #{original_todo_count + 1} added."
            )
            todo_file_lines = File.readlines(todo_file.path)
            expect(todo_file_lines.last).to match(
              /^{#{mit_date}} Play guitar @personal$/,
            )
            expect(todo_file_lines).to include(
              /^\(B\) {2016\.11\.29} Play guitar @personal$/,
            )
            expect(todo_file_lines.count).to eq(original_todo_count + 1)
          end
        end
      end
    end

    specify 'DAY can be of any case' do
      fixed_time = '2016-12-01'
      fixed_time_in_mit_form = '2016.12.01'
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @personal
      EOF
      original_todo_count = various_todos.split("\n").count

      with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
        executable = Executable.run(
          "cp 4 ToDaY",
          env_extension: env_extension
        )

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(
          /\A{#{fixed_time_in_mit_form}} Play guitar @personal\z/
        )
        expect(executable.lines).to include(
          "TODO: #{original_todo_count + 1} added."
        )
        todo_file_lines = File.readlines(todo_file.path)
        expect(todo_file_lines.last).to match(
          /^{#{fixed_time_in_mit_form}} Play guitar @personal$/,
        )
        expect(todo_file_lines).to include(
          /^\(B\) {2016\.11\.29} Play guitar @personal$/,
        )
        expect(todo_file_lines.count).to eq(original_todo_count + 1)
      end
    end
  end

  describe 'with the format `todo.sh mit cp 123 RELATIVE_DATE' do
    fixed_time = '2016-12-01'
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
      specify "a MIT is added with RELATIVE_DATE \"#{relative_date}\"" do
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF
        original_todo_count = various_todos.split("\n").count

        with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
          executable = Executable.run(
            "cp 4 #{relative_date}",
            env_extension: env_extension
          )

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).to include(
            /\A{#{mit_date}} Play guitar @personal\z/
          )
          expect(executable.lines).to include(
            "TODO: #{original_todo_count + 1} added."
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines.last).to match(
            /^{#{mit_date}} Play guitar @personal$/,
          )
          expect(todo_file_lines).to include(
            /^\(B\) {2016\.11\.29} Play guitar @personal$/,
          )
          expect(todo_file_lines.count).to eq(original_todo_count + 1)
        end
      end
    end
  end

  describe 'with the format `todo.sh mit cp 123 FREEFORM_DATE' do
    {
      '2010/03/22' => '2010.03.22',
      '22/03/2010' => '2010.03.22',
      '22-03-2010' => '2010.03.22',
      '14th' => /\d{4}\.\d{2}\.14/,
    }.each do |freeform_date, mit_date|
      specify "a MIT is added with FREEFORM_DATE \"#{freeform_date}\"" do
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF
        original_todo_count = various_todos.split("\n").count

        with_fixed_time_and_todo_file('2016-12-01', various_todos) do |todo_file, env_extension|
          executable = Executable.run(
            "cp 4 #{freeform_date}",
            env_extension: env_extension
          )

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).to include(
            /\A{#{mit_date}} Play guitar @personal\z/
          )
          expect(executable.lines).to include(
            "TODO: #{original_todo_count + 1} added."
          )
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines.last).to match(
            /^{#{mit_date}} Play guitar @personal$/,
          )
          expect(todo_file_lines).to include(
            /^\(B\) {2016\.11\.29} Play guitar @personal$/,
          )
          expect(todo_file_lines.count).to eq(original_todo_count + 1)
        end
      end
    end
  end

  describe 'automated addition of creation date to MITs' do
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

        with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
          mit_date = '2016.12.05'
          env_extension.merge!('TODOTXT_DATE_ON_ADD' => '1')

          executable = Executable.run(
            "cp 4 #{mit_date}",
            env_extension: env_extension
          )

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines.last).to match(
            /^#{fixed_time} {#{mit_date}} Play guitar @personal$/
          )
        end
      end
    end

    context 'ENV["TODOTXT_DATE_ON_ADD"] is not set' do
      specify 'a MIT without a creation date is added to the TODO_FILE' do
        fixed_time = '2016-12-01'
        various_todos = <<-EOF
          (A) Important email +read
          That long article @personal +read
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) {2016.11.29} Play guitar @personal
          2016-11-26 Make phone call @personal
        EOF

        with_fixed_time_and_todo_file(fixed_time, various_todos) do |todo_file, env_extension|
          mit_date = '2016.12.05'

          executable = Executable.run(
            "cp 4 #{mit_date}",
            env_extension: env_extension
          )

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          todo_file_lines = File.readlines(todo_file.path)
          expect(todo_file_lines.last).to match(
            /^{#{mit_date}} Play guitar @personal$/
          )
        end
      end
    end
  end
end
