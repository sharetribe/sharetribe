When(/^(\d+) days? have|has passed$/) do |number_of_days|
  Timecop.travel(number_of_days.to_i.days.from_now)
end

When(/^(\d+) seconds? have|has passed$/) do |number_of_seconds|
  Timecop.travel(number_of_seconds.to_i.seconds.from_now)
end

# Deprecated!
# Use When 30 days have passed (int, not string)
When /^"([^"]*)" days have passed$/ do |number_of_days|
  steps %Q{
    When #{number_of_days} days have passed
  }
end

When /^return to current time$/ do
  Timecop.return
end
