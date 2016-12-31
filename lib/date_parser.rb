class DateParser
  def initialize(date_string)
    @date_string = date_string
  end

  def parse
    Date.parse(@date_string)
  rescue ArgumentError
    nil
  end
end
