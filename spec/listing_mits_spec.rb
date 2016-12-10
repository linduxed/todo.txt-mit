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
    end
  end

  def with_fixed_time_and_todo_file(todos)
    Timecop.freeze(Time.new(2016, 12, 1)) do
      todo_file = Tempfile.new('todo.txt')
      todos.gsub!(/^\s+/, '')

      todo_file.write(todos)
      todo_file.close

      env_extension = { 'TODO_FILE' => todo_file.path }

      yield(env_extension)

      todo_file.delete
    end
  end
end
