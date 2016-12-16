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

        with_fixed_time_and_todo_file(no_mits) do |env_extension|
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

        with_fixed_time_and_todo_file(two_future_mits) do |env_extension|
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

      context 'with two MITs past due' do
        specify 'MITs are listed with "Past due"-header before them' do
          two_mits_past_due = <<-EOF
            2016-11-26 {2016.11.28} Make phone call @personal
            2016-11-26 {2016.11.29} Play guitar @personal
          EOF

          with_fixed_time_and_todo_file(two_mits_past_due) do |env_extension|
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
        specify 'MITs are listed with "Today"-header before them'
      end

      context 'with two MITs due tomorrow' do
        specify 'MITs are listed with "Tomorrow"-header before them'
      end
    end
  end

  def with_fixed_time_and_todo_file(todos)
    todo_file = Tempfile.new('todo.txt')
    todos.gsub!(/^\s+/, '')

    todo_file.write(todos)
    todo_file.close

    env_extension = {
      'TODO_FILE' => todo_file.path,
      'FIXED_DATE' => '2016-12-01',
    }

    yield(env_extension)

    todo_file.delete
  end
end
