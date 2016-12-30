class MIT
  def initialize(todo, number)
    @todo = todo
    @number = number
  end

  def date
    @date ||= Date.parse(@todo.match(Constants::MIT_DATE_REGEX)[1])
  end

  def to_s
    @to_s ||= "#{priority_token}#{task} (#{@number})"
  end

  def past_due?
    date < Constants::TODAY
  end

  private

  def task
    @todo.split(Constants::MIT_DATE_REGEX).last.strip
  end

  def priority_token
    if p = @todo.match(/\A\([A-Z]\) /) then p[0] else nil end
  end
end
