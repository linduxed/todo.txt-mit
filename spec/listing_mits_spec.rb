require 'spec_helper'

describe 'Listing MITs' do
  context 'user lists MITs with "todo.sh mit"' do
    context 'with no MITs' do
      specify 'a "No MITs found." message is printed' do
        no_mits = <<-EOF
          x 2016-11-30 2016-11-30 Buy milk @personal
          (B) 2016-11-25 Send email about delivery @work
          (C) 2016-10-25 That long article @personal +read
        EOF

        with_fixed_time_and_todo_file('2016-12-01', no_mits) do |env_extension|
          executable = Executable.run(env_extension: env_extension)

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines.count).to eq(1)
          expect(executable.lines.first).to eq('No MITs found.')
        end
      end
    end

    context 'with MITs present' do
      specify 'only MITs are listed' do
        two_future_mits = <<-EOF
          x 2016-11-30 2016-11-30 Buy milk @personal
          x 2016-11-30 2016-11-28 {2016.12.04} Read important email @personal
          (B) 2016-11-25 Send email about delivery @work
          (C) 2016-10-25 That long article @personal +read
          2016-11-26 {2016.12.06} Make phone call @personal
          2016-11-26 {2017.01.01} Update LICENSE file @personal
        EOF

        with_fixed_time_and_todo_file('2016-12-01', two_future_mits) do |env_extension|
          executable = Executable.run(env_extension: env_extension)

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)
          expect(executable.lines).not_to include(/Buy milk/)
          expect(executable.lines).not_to include(/Read important email/)
          expect(executable.lines).not_to include(/Send email about delivery/)
          expect(executable.lines).not_to include(/That long article/)
          expect(executable.lines).to include(/Make phone call/)
          expect(executable.lines).to include(/Update LICENSE file/)
        end
      end

      specify 'MITs are listed with their TODO-number and priority' do
        two_future_mits = <<-EOF
          x 2016-11-30 2016-11-30 Buy milk @personal
          x 2016-11-30 2016-11-28 {2016.12.04} Read important email @personal
          (B) 2016-11-26 {2016.12.06} Make phone call @personal
          (B) 2016-11-25 Send email about delivery @work
          (A) 2016-11-26 {2016.12.15} That long article @personal +read
        EOF

        with_fixed_time_and_todo_file('2016-12-01', two_future_mits) do |env_extension|
          executable = Executable.run(env_extension: env_extension)

          expect(executable.error).to be_empty, "Error:\n#{executable.error}"
          expect(executable.exit_code).to eq(0)

          phone_call_line = executable.lines.find do |line|
            line.match(/Make phone call/)
          end
          expect(phone_call_line).to match(/\(B\)/)
          expect(phone_call_line).to match(/\(3\)/)

          long_article_line = executable.lines.find do |line|
            line.match(/That long article/)
          end
          expect(long_article_line).to match(/\(A\)/)
          expect(long_article_line).to match(/\(5\)/)
        end
      end

      context 'with two MITs past due' do
        specify 'MITs are listed with "Past due"-header before them' do
          two_mits_past_due = <<-EOF
            2016-11-26 {2016.11.28} Make phone call @personal
            2016-11-26 {2016.11.29} Play guitar @personal
          EOF

          with_fixed_time_and_todo_file('2016-12-01', two_mits_past_due) do |env_extension|
            executable = Executable.run(env_extension: env_extension)

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(/\Apast due/i)
            past_due_header_line = executable.lines.index do |line|
              line.match(/\Apast due/i)
            end
            lines_following_header =
              executable.lines[past_due_header_line + 1..-1]
            expect(lines_following_header).to include(/Make phone call/)
            expect(lines_following_header).to include(/Play guitar/)
          end
        end
      end

      context 'with two MITs due today' do
        specify 'MITs are listed with "Today"-header before them' do
          two_mits_today = <<-EOF
            2016-11-26 {2016.12.01} Make phone call @personal
            2016-11-26 {2016.12.01} Play guitar @personal
          EOF

          with_fixed_time_and_todo_file('2016-12-01', two_mits_today) do |env_extension|
            executable = Executable.run(env_extension: env_extension)

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(/\Atoday/i)
            today_header_line = executable.lines.index do |line|
              line.match(/\Atoday/i)
            end
            lines_following_header =
              executable.lines[today_header_line + 1..-1]
            expect(lines_following_header).to include(/Make phone call/)
            expect(lines_following_header).to include(/Play guitar/)
          end
        end
      end

      context 'with two MITs due tomorrow' do
        specify 'MITs are listed with "Tomorrow"-header before them' do
          two_mits_tomorrow = <<-EOF
            2016-11-26 {2016.12.02} Make phone call @personal
            2016-11-26 {2016.12.02} Play guitar @personal
          EOF

          with_fixed_time_and_todo_file('2016-12-01', two_mits_tomorrow) do |env_extension|
            executable = Executable.run(env_extension: env_extension)

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(/\Atomorrow/i)
            tomorrow_header_line = executable.lines.index do |line|
              line.match(/\Atomorrow/i)
            end
            lines_following_header =
              executable.lines[tomorrow_header_line + 1..-1]
            expect(lines_following_header).to include(/Make phone call/)
            expect(lines_following_header).to include(/Play guitar/)
          end
        end
      end

      context 'with three MITs due in 3-7 days' do
        specify 'MITs are listed with weekday headers before them' do
          two_mits_tomorrow = <<-EOF
            2016-11-26 {2016.12.05} Make phone call @personal
            2016-11-26 {2016.12.06} Respond to email @work
            2016-11-26 {2016.12.08} Send email about delivery @work
          EOF

          with_fixed_time_and_todo_file('2016-12-01', two_mits_tomorrow) do |env_extension|
            executable = Executable.run(env_extension: env_extension)

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(/\AMonday/)
            expect(executable.lines).to include(/\ATuesday/)
            expect(executable.lines).to include(/\AThursday/)

            monday_header_line = executable.lines.index do |line|
              line.match(/\AMonday/)
            end
            line_following_header = executable.lines[monday_header_line + 1]
            expect(line_following_header).to match(/Make phone call/)

            tuesday_header_line = executable.lines.index do |line|
              line.match(/\ATuesday/)
            end
            line_following_header = executable.lines[tuesday_header_line + 1]
            expect(line_following_header).to match(/Respond to email/)

            thursday_header_line = executable.lines.index do |line|
              line.match(/\AThursday/)
            end
            line_following_header = executable.lines[thursday_header_line + 1]
            expect(line_following_header).to match(/Send email about delivery/)
          end
        end
      end

      context 'with a MIT due in >7 days during next week' do
        specify 'MIT is listed with "next week"-header before it' do
          one_mit_next_week = <<-EOF
            2016-11-26 {2016.12.09} Make phone call @personal
          EOF

          with_fixed_time_and_todo_file('2016-12-01', one_mit_next_week) do |env_extension|
            executable = Executable.run(env_extension: env_extension)

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(/\AFriday.+next week/)

            next_week_header_line = executable.lines.index do |line|
              line.match(/\AFriday.+next week/)
            end
            line_following_header = executable.lines[next_week_header_line + 1]
            expect(line_following_header).to match(/Make phone call/)
          end
        end
      end

      context 'with three MITs due in >7 days, not next week' do
        specify 'MITs are listed with headers with week count before them' do
          three_future_mits = <<-EOF
            2016-11-26 {2016.12.15} Make phone call @personal
            2016-11-26 {2017.01.01} Update LICENSE file @personal
            2016-11-26 {2017.01.09} Send email about delivery @work
          EOF

          with_fixed_time_and_todo_file('2016-12-01', three_future_mits) do |env_extension|
            executable = Executable.run(env_extension: env_extension)

            expect(executable.error).to be_empty, "Error:\n#{executable.error}"
            expect(executable.exit_code).to eq(0)
            expect(executable.lines).to include(/\AThursday.+2 weeks/)
            expect(executable.lines).to include(/\ASunday.+4 weeks/)
            expect(executable.lines).to include(/\AMonday.+6 weeks/)

            two_week_header_line = executable.lines.index do |line|
              line.match(/\AThursday.+2 weeks/)
            end
            line_following_header = executable.lines[two_week_header_line + 1]
            expect(line_following_header).to match(/Make phone call/)

            four_week_header_line = executable.lines.index do |line|
              line.match(/\ASunday.+4 weeks/)
            end
            line_following_header = executable.lines[four_week_header_line + 1]
            expect(line_following_header).to match(/Update LICENSE file/)

            six_week_header_line = executable.lines.index do |line|
              line.match(/\AMonday.+6 weeks/)
            end
            line_following_header = executable.lines[six_week_header_line + 1]
            expect(line_following_header).to match(/Send email about delivery/)
          end
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

    yield(env_extension)

    todo_file.delete
  end
end
