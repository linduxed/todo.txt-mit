require_relative 'date_formatter'

class MITListPrinter
  def initialize(todo_file_path)
    @todo_file_path = todo_file_path
  end

  def all_mits
    return 'No MITs found.' if mits_from_file.empty?

    grouped_by_date(mits_from_file)
  end

  def mits_with_context(context:)
    context_mits = mits_from_file.select { |mit| mit.context?(context) }
    return 'No MITs found.' if context_mits.empty?

    grouped_by_date(context_mits)
  end

  def mits_without_context(context:)
    not_context_mits = mits_from_file.reject { |mit| mit.context?(context) }
    return 'No MITs found.' if not_context_mits.empty?

    grouped_by_date(not_context_mits)
  end

  private

  def mits_from_file
    @mits_from_file ||= TodoFileParser.new(@todo_file_path).mits
  end

  def grouped_by_date(mits)
    output_lines = []

    if mits.any?(&:past_due?)
      output_lines << 'Past due:'
      mits.select(&:past_due?).each do |mit|
        output_lines << "  #{mit}"
      end
      output_lines << ''
    end

    mits_today_or_in_future = mits.reject(&:past_due?).group_by(&:date)
    sorted_dates = mits_today_or_in_future.keys.sort

    sorted_dates.each do |date|
      mits_for_date = mits_today_or_in_future[date]

      output_lines << DateFormatter.new(date).format
      mits_for_date.each do |mit|
        output_lines << "  #{mit}"
      end
      output_lines << ''
    end

    output_lines.join("\n")
  end
end
