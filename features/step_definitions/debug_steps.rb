Then /^open Pry$/ do
  binding.pry
end

Then /^I debug$/ do
  "Debug step in RubyMine"
end

Then /^save and open page$/ do
  save_and_open_screenshot
  save_and_open_page
end
