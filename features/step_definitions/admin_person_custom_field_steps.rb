When(/^I add a new person custom field "(.*?)"$/) do |field_name|
  steps %{
    When I select "Dropdown" from "field_type"
    And I fill in "custom_field_name_attributes_en" with "#{field_name}"
    And I fill in "custom_field_name_attributes_fi" with "Talon tyyppi"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_en" with "Room"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_fi" with "Huone"
    And I fill in "custom_field_option_attributes_new-2_title_attributes_en" with "Appartment"
    And I fill in "custom_field_option_attributes_new-2_title_attributes_fi" with "Asunto"
    And I follow "custom-fields-add-option"
    When I fill in "custom_field_option_attributes_jsnew-1_title_attributes_en" with "House"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_fi" with "Talo"
    And I press submit
  }
end

When(/^I add a new person custom field "(.*?)" with invalid data$/) do |field_name|
  steps %{
    When I select "Dropdown" from "field_type"
    And I fill in "custom_field_name_attributes_en" with "#{field_name}"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_en" with "Room"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_fi" with "Huone"
    And I fill in "custom_field_option_attributes_new-2_title_attributes_en" with "Appartment"
    And I follow "custom-fields-add-option"
    When I fill in "custom_field_option_attributes_jsnew-1_title_attributes_en" with "House"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_fi" with "Talo"
    And I press submit
  }
end

When(/^I add a new person numeric field "(.*?)" with min value (\d+) and max value (\d+)$/) do |field_name, min, max|
  steps %{
    When I select "Number" from "field_type"
    And I fill in "custom_field_name_attributes_en" with "#{field_name}"
    And I fill in "custom_field_name_attributes_fi" with "Pinta-ala"
    And I set numeric field min value to #{min}
    And I set numeric field max value to #{max}
    And I press submit
  }
end

When(/^I add a new person checkbox field Amenities$/) do
  steps %{
    When I select "Checkbox" from "field_type"
    And I fill in "custom_field_name_attributes_en" with "Amenities"
    And I fill in "custom_field_name_attributes_fi" with "Mukavuudet"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_en" with "Wireless Internet"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_fi" with "Langaton Internet"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_en" with "Sauna"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_fi" with "Sauna"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field_option_attributes_jsnew-2_title_attributes_en" with "Hot Tub"
    And I fill in "custom_field_option_attributes_jsnew-2_title_attributes_fi" with "Poreamme"
    And I press submit
  }
end

When(/^I add a new person checkbox field Amenities with invalid data$/) do
  steps %{
    When I select "Checkbox" from "field_type"
    And I fill in "custom_field_name_attributes_en" with "Amenities"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_en" with "Wireless Internet"
    And I fill in "custom_field_option_attributes_new-1_title_attributes_fi" with "Langaton Internet"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_en" with "Sauna"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_fi" with "Sauna"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field_option_attributes_jsnew-2_title_attributes_en" with "Hot Tub"
    And I fill in "custom_field_option_attributes_jsnew-2_title_attributes_fi" with "Poreamme"
    And I press submit
  }
end

When(/^I add a new person date field "(.*?)"$/) do |field_name|
  steps %{
    When I select "Date" from "field_type"
    And I fill in "custom_field_name_attributes_en" with "#{field_name}"
    And I fill in "custom_field_name_attributes_fi" with "aika"
    And I press submit
  }
end

When(/^I change person custom field "(.*?)" name to "(.*?)"$/) do |old_name, new_name|
  steps %{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I fill in "custom_field_name_attributes_en" with "#{new_name}"
    And I press submit
  }
end

When(/^I edit person dropdown "(.*?)" options$/) do |field_name|
  steps %{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I fill in "custom_field_option_attributes_#{@custom_field.options[1].id}_title_attributes_en" with "House2"
    And I fill in "custom_field_option_attributes_#{@custom_field.options[1].id}_title_attributes_fi" with "Talo2"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_en" with "House3"
    And I fill in "custom_field_option_attributes_jsnew-1_title_attributes_fi" with "Talo3"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field_option_attributes_jsnew-2_title_attributes_en" with "House4"
    And I fill in "custom_field_option_attributes_jsnew-2_title_attributes_fi" with "Talo4"
    And I follow "custom-field-option-remove-#{@custom_field.options[0].id}"
    And I press submit
  }
end

