require 'spec_helper'

describe 'Filtering MITs with contexts' do
  describe 'with the format `todo.sh mit @foobar`' do
    specify 'only MITs with @foobar context get listed' do
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 Make phone call @work
      EOF

      with_fixed_time_and_todo_file('2016-12-01', various_todos) do |_, env_extension|
        executable = Executable.run('@personal', env_extension: env_extension)

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(/Play guitar/)
        expect(executable.lines).not_to include(/Important email/)
        expect(executable.lines).not_to include(/That long article/)
        expect(executable.lines).not_to include(/Buy milk/)
        expect(executable.lines).not_to include(/Make phone call/)
      end
    end
  end

  describe 'with the format `todo.sh mit not @foobar`' do
    specify 'all MITs without @foobar context get listed' do
      various_todos = <<-EOF
        (A) Important email +read
        That long article @personal +read
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) {2016.11.29} Play guitar @personal
        2016-11-26 {2016.11.30} Make phone call @work
      EOF

      with_fixed_time_and_todo_file('2016-12-01', various_todos) do |_, env_extension|
        executable = Executable.run('not @personal', env_extension: env_extension)

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines).to include(/Make phone call/)
        expect(executable.lines).not_to include(/Important email/)
        expect(executable.lines).not_to include(/That long article/)
        expect(executable.lines).not_to include(/Buy milk/)
        expect(executable.lines).not_to include(/Play guitar/)
      end
    end
  end

  context 'with no MITs' do
    specify 'a "No MITs found." message is printed' do
      no_mits = <<-EOF
        x 2016-11-30 2016-11-30 Buy milk @personal
        (B) 2016-11-25 Send email about delivery @work
        (C) 2016-10-25 That long article @personal +read
      EOF

      with_fixed_time_and_todo_file('2016-12-01', no_mits) do |_, env_extension|
        executable = Executable.run('@foobar', env_extension: env_extension)

        expect(executable.error).to be_empty, "Error:\n#{executable.error}"
        expect(executable.exit_code).to eq(0)
        expect(executable.lines.count).to eq(1)
        expect(executable.lines.first).to eq('No MITs found.')
      end
    end
  end
end
