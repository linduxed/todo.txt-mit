require 'spec_helper'

describe 'Printing version' do
  context 'user requests version with "todo.sh mit -v"' do
    specify 'version message is printed' do
      executable = Executable.run('-v')

      expect(executable.error).to be_empty, "Error:\n#{executable.error}"
      expect(executable.exit_code).to eq(0)
      expect(executable.lines).to include(/mit.+v\d+\.\d+\.\d+/)
    end
  end

  context 'user requests usage with "todo.sh mit --version"' do
    specify 'version message is printed' do
      executable = Executable.run('--version')

      expect(executable.error).to be_empty, "Error:\n#{executable.error}"
      expect(executable.exit_code).to eq(0)
      expect(executable.lines).to include(/mit.+v\d+\.\d+\.\d+/)
    end
  end
end
