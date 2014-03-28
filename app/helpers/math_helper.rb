# Math helper contains some of the most commonly used math operations
module MathHelper

  def sum_with_percentage(sum, percentage)
    percentage = 0 if percentage.nil?
    sum + (sum * percentage / 100)
  end

end
