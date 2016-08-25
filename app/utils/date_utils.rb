module DateUtils
  module_function

  def from_date_select(hash, name)
    date_arr = [1, 2, 3].map { |i| hash["#{name.to_s}(#{i}i)"].to_i }
    Date.new *date_arr
  end

  def duration_days(start_date, end_date, include_last:)
    last_day = include_last ? 1 : 0

    (end_date - start_date).to_i + last_day
  end
end
