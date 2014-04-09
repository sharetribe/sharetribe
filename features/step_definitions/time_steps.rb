When /^"([^"]*)" days have passed$/ do |number_of_days|
  Timecop.travel(DateTime.now + number_of_days.to_i)
end

When /^return to current time$/ do
  Timecop.return
end
