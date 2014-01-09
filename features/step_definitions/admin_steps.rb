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

Then /^I should see that I do not have any custom fields$/ do
  steps %Q{
    Then I should see "No marketplace specific listing fields"
  }
end

When /^I remove custom field "(.*?)"$/ do |title|
  find_remove_link_for_custom_field(title).click()
end

When /^I toggle category "(.*?)"$/ do |category|
  find(:css, "label", :text => category).click()
end

When /^I add a new custom field "(.*?)"$/ do |field_name|
  steps %Q{
    When I follow "add-new-field-link"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[name_attributes][fi]" with "Talon tyyppi"
    And I toggle category "Spaces"
    And I fill in "custom_field[option_attributes][0][title_attributes][en]" with "Room"
    And I fill in "custom_field[option_attributes][0][title_attributes][fi]" with "Huone"
    And I fill in "custom_field[option_attributes][1][title_attributes][en]" with "Appartment"
    And I fill in "custom_field[option_attributes][1][title_attributes][fi]" with "Asunto"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][2][title_attributes][en]" with "House"
    And I fill in "custom_field[option_attributes][2][title_attributes][fi]" with "Talo"
    And I press submit
  }
end

When /^I add a new custom field "(.*?)" with invalid data$/ do |field_name|
  steps %Q{
    When I follow "add-new-field-link"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[option_attributes][0][title_attributes][en]" with "Room"
    And I fill in "custom_field[option_attributes][0][title_attributes][fi]" with "Huone"
    And I fill in "custom_field[option_attributes][1][title_attributes][en]" with "Appartment"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][2][title_attributes][en]" with "House"
    And I fill in "custom_field[option_attributes][2][title_attributes][fi]" with "Talo"
    And I press submit
  }
end