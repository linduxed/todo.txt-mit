require 'spec_helper'

describe 'Adding a MIT date to a TODO' do
  describe 'with the format `todo.sh mit mv 123 YYYY.MM.DD`' do
    context 'TODO has a creation date' do
      context 'TODO does not have a priority' do
        specify 'TODO gets a MIT date after the creation date'
      end

      context 'TODO has a priority' do
        specify 'TODO gets a MIT date after the creation date'
      end
    end

    context 'TODO does not have a creation date' do
      context 'TODO does not have a priority' do
        specify 'TODO gets a MIT date at the start of the line'
      end

      context 'TODO has a priority' do
        specify 'TODO gets a MIT date after the priority'
      end
    end
  end

  describe 'with the format `todo.sh mit mv 123 WEEKDAY`' do
    specify 'TODO gets a MIT date for WEEKDAY'
  end

  context 'TODO is completed' do
    context 'TODO has neither creation date nor completion date' do
      specify 'completed TODO gets a MIT date after leading "x"'
    end

    context 'TODO has completion date' do
      specify 'completed TODO gets a MIT date after leading "x" and date'
    end

    context 'TODO has completion and creation date' do
      specify 'completed TODO gets a MIT date after leading "x" and dates'
    end
  end
end
