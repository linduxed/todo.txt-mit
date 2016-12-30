require_relative 'date_formatter'

class MITListFormatter
  def initialize(mits)
    @mits = mits
  end

  def grouped_by_date
    output_lines = []

    if @mits.any?(&:past_due?)
      output_lines << 'Past due:'
      @mits.select(&:past_due?).each do |mit|
        output_lines << "  #{mit}"
      end
      output_lines << ''
    end

    mits_today_or_in_future = @mits.reject(&:past_due?).group_by(&:date)
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
