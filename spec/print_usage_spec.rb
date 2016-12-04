require 'spec_helper'

describe 'Printing usage' do
  context 'user invokes usage with "todo.sh help"' do
    specify 'usage message is printed' do
      executable = Executable.run(
        'usage',
        prepend_program_name_to_args: false
      )

      expect(executable.error).to be_empty, "Error:\n#{executable.error}"
      expect(executable.exit_code).to eq(0)
      usage_message_shown?(executable)
    end
  end

  context 'user requests usage with "todo.sh mit usage"' do
    specify 'usage message is printed' do
      executable = Executable.run('usage')

      expect(executable.error).to be_empty, "Error:\n#{executable.error}"
      expect(executable.exit_code).to eq(0)
      usage_message_shown?(executable)
    end
  end

  context 'user requests usage with "todo.sh mit --help"' do
    specify 'usage message is printed' do
      executable = Executable.run('--help')

      expect(executable.error).to be_empty, "Error:\n#{executable.error}"
      expect(executable.exit_code).to eq(0)
      usage_message_shown?(executable)
    end
  end

  context 'user requests usage with "todo.sh mit -h"' do
    specify 'usage message is printed' do
      executable = Executable.run('-h')

      expect(executable.error).to be_empty, "Error:\n#{executable.error}"
      expect(executable.exit_code).to eq(0)
      usage_message_shown?(executable)
    end
  end

  def usage_message_shown?(executable)
    expect(executable.lines).not_to be_empty
    [
      /MIT/,
      /-h.+--help.+help/,
      /-v.+--version.+version/,
    ].each do |regex|
      expect(executable.lines).to include(regex)
    end
  end
end
