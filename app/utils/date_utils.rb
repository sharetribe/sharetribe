module DateUtils
  module_function

  def from_date_select(hash, name)
    date_arr = [1, 2, 3].map { |i| hash["#{name.to_s}(#{i}i)"].to_i }
    Date.new *date_arr
  end

  def duration(start_date, end_date)
    (end_date - start_date).to_i
  end

  def to_midnight_utc(date)
    Time.utc(date.year, date.month, date.day)
  end

  def duration_in_hours(start_time, end_time)
    (end_time - start_time).to_i / 1.hour.to_i
  end
end
