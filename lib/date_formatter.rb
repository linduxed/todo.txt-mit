class DateFormatter
  def initialize(date)
    @date = date
  end

  def format(with_trailing_colon:, capitalize:)
    formatted_date =
      case
      when in_the_past?
        @date.to_s
      when today?
        capitalize ? 'Today' : 'today'
      when tomorrow?
        "#{capitalize ? 'Tomorrow' : 'tomorrow'}, #{weekday}"
      when within_seven_days?
        weekday
      when next_week?
        "#{weekday}, next week, #{@date}"
      else
        "#{weekday}, #{number_of_weeks_from_now} weeks from now, #{@date}"
      end

    with_trailing_colon ? "#{formatted_date}:" : formatted_date
  end

  private

  def in_the_past?
    @date < Constants::TODAY
  end

  def today?
    @date == Constants::TODAY
  end

  def tomorrow?
    @date == Constants::TODAY + 1
  end

  def within_seven_days?
    @date <= Constants::TODAY + 7
  end

  def next_week?
    @date.cweek == (Constants::TODAY + 7).cweek
  end

  def number_of_weeks_from_now
    # To account for potential transitions between years when counting weeks
    # into the future, step forward week by week and check if the date of the
    # first day that week matches.
    #
    # As the case-statement above has already handled the "next week"-case,
    # start from two weeks into the future.
    two_weeks = 14
    days_in_week = 7

    days_away_from_matching_week =
      (two_weeks..Float::INFINITY).
      step(days_in_week).
      find do |days_into_future|
        future = Constants::TODAY + days_into_future.to_i

        start_of_week_for_date = @date - @date.cwday
        start_of_week_in_future = future - future.cwday

        start_of_week_for_date == start_of_week_in_future
      end.to_i

    days_away_from_matching_week / days_in_week
  end

  def weekday
    Date::DAYNAMES[@date.wday]
  end
end
