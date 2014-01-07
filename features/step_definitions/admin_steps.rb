LIST_SELECTOR = "#custom-fields-list"
REMOVE_SELECTOR = ".custom-fields-action-remove"

module AdminSteps

  def find_row_for_custom_field(title)
    list = find(LIST_SELECTOR)
    title_div = list.find(".row", :text => "#{title}")
    custom_field_row = title_div.first(:xpath, ".//..")
  end

  def find_remove_link_for_custom_field(title)
    find_row_for_custom_field(title).find(REMOVE_SELECTOR)
  end
end

World(AdminSteps)

Then /^I should see that there is a custom field "(.*?)"$/ do |field_name|
  steps %Q{
    Then I should see "#{field_name}" within "#{LIST_SELECTOR}"
  }
end

Then /^I should see that there is no custom field "(.*?)"$/ do |field_name|
  steps %Q{
    Then I should not see "#{field_name}" within "#{LIST_SELECTOR}"
  }
end

When /^I remove custom field "(.*?)"$/ do |title|
  find_remove_link_for_custom_field(title).click()
end