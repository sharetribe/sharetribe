module AdminLookAndFeelSteps

  # "#FF0044" -> [255, 0, 68]
  def hexToRgb(hex)
    hex.split("#").last.scan(/../).map { |s| s.to_i(16) }
  end
end

World(AdminLookAndFeelSteps)

When(/^I set the main color to "(.*?)"$/) do |color|
  steps %Q{ And I fill in "community[custom_color1]" with "#{color}" }
end

Then(/^I should see that the background color of Post a new listing button is "(.*?)"$/) do |color|
  expected_color = "rgb(#{hexToRgb(color).join(", ")})"
  steps %Q{
    Then "#new-listing-link" should have CSS property "background-color" with value "#{expected_color}"
  }
end
