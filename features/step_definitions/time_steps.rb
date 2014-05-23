When(/^(\d+) days? have|has passed$/) do |number_of_days|
  Timecop.travel(DateTime.now + number_of_days.to_i)
end

When(/^(\d+) second? have|has passed$/) do |number_of_seconds|
  Timecop.travel(DateTime.now + number_of_seconds.to_i.seconds)
end

# Deprecated!
# Use When 30 days have passed (int, not string)
When /^"([^"]*)" days have passed$/ do |number_of_days|
  steps %Q{
    When #{number_of_days} have passed
  }
end

When /^return to current time$/ do
  Timecop.return
end
