When 'the system processes jobs' do
  Delayed::Worker.new(:quiet => true).work_off
end

When /^I print "(.+)"$/ do |text|
  puts text
end
