When /^"([^"]*)" days have passed$/ do |number_of_days|
  puts "Timecop here"
  puts "Time now before: #{DateTime.now}"
  Timecop.freeze(DateTime.now + number_of_days.to_i)
  puts "Time now after: #{DateTime.now}"
end

When /^return to current time$/ do
  Timecop.return
end