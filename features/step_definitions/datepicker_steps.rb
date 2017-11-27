When(/^I click on datepicker day "(.+)"$/) do |day|
  find('.datepicker-days .day:not(.disabled)', text: day, match: :prefer_exact).click
end

