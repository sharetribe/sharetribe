Given /^I use subdomain "([^"]*)"$/ do |subdomain|
  #visit("http://#{subdomain}.lvh.me:9887") 
  Capybara.default_host = "#{subdomain}.lvh.me"
  Capybara.app_host = "http://#{subdomain}.lvh.me:9887" if Capybara.current_driver == :culerity
end

When 'the system processes jobs' do
  Delayed::Worker.new(:quiet => true).work_off
end

When /^I print "(.+)"$/ do |text|
  puts text
end

