require_relative 'constants'

class DateParser
  def initialize(date_string)
    @date_string = date_string.downcase
  end

  def parse
    maybe_fixed_date ||
      maybe_weekday ||
      maybe_relative_date ||
      maybe_constraint_free_parse
  end

  private

  def maybe_fixed_date
    fixed_dates = {
      'today' => Constants::TODAY,
      'tomorrow' => Constants::TODAY + 1,
    }

    fixed_dates.fetch(@date_string, nil)
  end

  def maybe_weekday
    weekday_name_to_cwday = {
      'monday' => 1,
      'tuesday' => 2,
      'wednesday' => 3,
      'thursday' => 4,
      'friday' => 5,
      'saturday' => 6,
      'sunday' => 7,
      'mon' => 1,
      'tue' => 2,
      'wed' => 3,
      'thu' => 4,
      'fri' => 5,
      'sat' => 6,
      'sun' => 7,
    }

    return nil unless weekday_name_to_cwday.keys.include?(@date_string)

    from_tomorrow_to_one_week_from_now = (1..7).map do |days_into_future|
      Constants::TODAY + days_into_future
    end

    from_tomorrow_to_one_week_from_now.find do |day|
      day.cwday == weekday_name_to_cwday[@date_string]
    end
  end

  def maybe_relative_date
    matches = @date_string.downcase.match(/\A(\d+)([dwm])\z/i)
    return nil if matches.nil?

    number, time_period = matches[1].to_i, matches[2]

    case time_period
    when 'd'
      Constants::TODAY + number
    when 'w'
      Constants::TODAY + (7 * number)
    when 'm'
      Constants::TODAY >> number
    end
  end

  def maybe_constraint_free_parse
    Date.parse(@date_string)
  rescue ArgumentError
    nil
  end
end
