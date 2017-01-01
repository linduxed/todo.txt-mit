require_relative 'constants'

class DateParser
  def initialize(date_string)
    @date_string = date_string.downcase
  end

  def parse
    fixed_dates = {
      'today' => Constants::TODAY,
      'tomorrow' => Constants::TODAY + 1,
    }

    fixed_dates.fetch(@date_string, nil) || Date.parse(@date_string)
  rescue ArgumentError
    nil
  end
end
