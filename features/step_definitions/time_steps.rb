When /^"([^"]*)" days have passed$/ do |number_of_days|
  Timecop.freeze(DateTime.now + number_of_days)
end

When /^return to current time$/ do
  Timecop.return
end