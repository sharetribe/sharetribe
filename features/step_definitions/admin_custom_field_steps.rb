LIST_SELECTOR = "#custom-fields-list"
REMOVE_SELECTOR = ".custom-fields-action-remove"
EDIT_SELECTOR = ".custom-fields-action-edit"
UP_SELECTOR = ".custom-fields-action-up"

module AdminCustomFieldSteps

  def find_row_for_custom_field(title)
    find(".custom-field-list-row", :text => "#{title}")
  end

  def find_remove_link_for_custom_field(title)
    find_row_for_custom_field(title).find(REMOVE_SELECTOR)
  end

  def find_edit_link_for_custom_field(title)
    find_row_for_custom_field(title).find(EDIT_SELECTOR)
  end

  def find_up_link_for_custom_field(title)
    find_row_for_custom_field(title).find(UP_SELECTOR)
  end

  def find_custom_field_by_name(field_name)
    @custom_fields.inject("") do |memo, f|
      memo = f if f.name.eql?(field_name)
      memo
    end
  end

end

World(AdminCustomFieldSteps)

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
  all(".custom-field-title").should be_empty
end

When /^I remove custom field "(.*?)"$/ do |title|
  steps %Q{
    Given I will confirm all following confirmation dialogs in this page if I am running PhantomJS
  }
  find_remove_link_for_custom_field(title).click
  steps %Q{
    And I confirm alert popup
  }
end

When /^I toggle category "(.*?)"$/ do |category|
  find(:css, "label", :text => category).click()
end

When /^I add a new custom field "(.*?)"$/ do |field_name|
  steps %Q{
    When I select "Dropdown" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[name_attributes][fi]" with "Talon tyyppi"
    And I toggle category "Spaces"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][en]" with "Room"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][fi]" with "Huone"
    And I fill in "custom_field[option_attributes][new-2][title_attributes][en]" with "Appartment"
    And I fill in "custom_field[option_attributes][new-2][title_attributes][fi]" with "Asunto"
    And I follow "custom-fields-add-option"
    When I fill in "custom_field[option_attributes][jsnew-1][title_attributes][en]" with "House"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][fi]" with "Talo"
    And I press submit
  }
end

When(/^I set numeric field min value to (\d+)$/) do |value|
  steps %Q{
    And I fill in "custom_field[min]" with "#{value}"
  }
end

When(/^I set numeric field max value to (\d+)$/) do |value|
  steps %Q{
    And I fill in "custom_field[max]" with "#{value}"
  }
end

When /^I add a new numeric field "(.*?)" with min value (\d+) and max value (\d+)$/ do |field_name, min, max|
  steps %Q{
    When I select "Number" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[name_attributes][fi]" with "Pinta-ala"
    And I toggle category "Spaces"
    And I set numeric field min value to #{min}
    And I set numeric field max value to #{max}
    And I press submit
  }
end

When /^I add a new date field "(.*?)"$/ do |field_name|
  steps %Q{
    When I select "Date" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[name_attributes][fi]" with "aika"
    And I toggle category "Spaces"
    And I press submit
  }
end

When /^I add a new custom field "(.*?)" with invalid data$/ do |field_name|
  steps %Q{
    When I select "Dropdown" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][en]" with "Room"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][fi]" with "Huone"
    And I fill in "custom_field[option_attributes][new-2][title_attributes][en]" with "Appartment"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][en]" with "House"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][fi]" with "Talo"
    And I press submit
  }
end

When /^I add a new checkbox field Amenities$/ do
  steps %Q{
    When I select "Checkbox" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "Amenities"
    And I fill in "custom_field[name_attributes][fi]" with "Mukavuudet"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][en]" with "Wireless Internet"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][fi]" with "Langaton Internet"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][en]" with "Sauna"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][fi]" with "Sauna"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][jsnew-2][title_attributes][en]" with "Hot Tub"
    And I fill in "custom_field[option_attributes][jsnew-2][title_attributes][fi]" with "Poreamme"
    And I toggle category "Spaces"
    And I press submit
  }
end

When /^I add a new checkbox field Amenities with invalid data$/ do
  steps %Q{
    When I select "Checkbox" from "field_type"
    And I fill in "custom_field[name_attributes][en]" with "Amenities"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][en]" with "Wireless Internet"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][fi]" with "Langaton Internet"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][en]" with "Sauna"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][fi]" with "Sauna"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][jsnew-2][title_attributes][en]" with "Hot Tub"
    And I fill in "custom_field[option_attributes][jsnew-2][title_attributes][fi]" with "Poreamme"
    And I press submit
  }
end

Given /^there is a custom field "(.*?)" in community "(.*?)" for category "(.*?)"$/ do |name, community, category_name|
  current_community = Community.find_by_domain(community)
  @custom_field = FactoryGirl.build(:custom_dropdown_field, {
    :community_id => current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")],
    :category_custom_fields => [FactoryGirl.build(:category_custom_field, :category => find_category_by_name(category_name), :custom_field => @custom_field)],
  })
  @custom_field.save
end

Given /^there is a numeric field "(.*?)" in community "(.*?)" for category "(.*?)" with min value "(.*?)" and max value "(.*?)"$/ do |name, community, category_name, min, max|
  current_community = Community.find_by_domain(community)
  @custom_field = FactoryGirl.build(:custom_numeric_field, {
    :community_id => current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")],
    :category_custom_fields => [FactoryGirl.build(:category_custom_field, :category => find_category_by_name(category_name), :custom_field => @custom_field)],
    :min => min.to_i,
    :max => max.to_i
  })
  @custom_field.save
end

When /^I change custom field "(.*?)" name to "(.*?)"$/ do |old_name, new_name|
  steps %Q{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I fill in "custom_field[name_attributes][en]" with "#{new_name}"
    And I press submit
  }
end

When /^I change custom field "(.*?)" categories$/ do |field_name|
  steps %Q{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I toggle category "#{@custom_field.community.categories[0].display_name("en")}"
    And I toggle category "#{@custom_field.community.categories[1].display_name("en")}"
    And I press submit
  }
end

Then /^correct categories should be stored$/ do
  @custom_field.categories.should == [@custom_field.community.categories[0]]
end

When /^I try to remove all categories$/ do
  steps %Q{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I toggle category "#{@custom_field.categories.first.display_name("en")}"
    And I press submit
  }
end

When /^I edit dropdown "(.*?)" options$/ do |field_name|
  steps %Q{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I fill in "custom_field[option_attributes][#{@custom_field.options[1].id}][title_attributes][en]" with "House2"
    And I fill in "custom_field[option_attributes][#{@custom_field.options[1].id}][title_attributes][fi]" with "Talo2"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][en]" with "House3"
    And I fill in "custom_field[option_attributes][jsnew-1][title_attributes][fi]" with "Talo3"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][jsnew-2][title_attributes][en]" with "House4"
    And I fill in "custom_field[option_attributes][jsnew-2][title_attributes][fi]" with "Talo4"
    And I follow "custom-field-option-remove-#{@custom_field.options[0].id}"
    And I press submit
  }
end

Then /^options should be stored correctly$/ do
  @custom_field = CustomField.find(@custom_field.id)
  @custom_field.options.size.should == 3
  @custom_field.options[0].title.should == "House2"
  @custom_field.options[1].title.should == "House3"
  @custom_field.options[2].title.should == "House4"
end

Then /^I should see "(.*?)" before "(.*?)"$/ do |arg1, arg2|
  steps %Q{
    Then I should see "#{arg1}"
    Then I should see "#{arg2}"
  }

  # http://stackoverflow.com/questions/8423576/is-it-possible-to-test-the-order-of-elements-via-rspec-capybara
  page.body.index(arg1).should < page.body.index(arg2)
end

When /^I move custom field "(.*?)" up$/ do |custom_field|
  find_up_link_for_custom_field(custom_field).click();
  steps %Q{
    Then I should see "Successfully saved field order"
  }
end

Given /^there is a custom dropdown field "(.*?)" in community "(.*?)"(?: in category "([^"]*)")? with options:$/ do |name, community, category_name, options|
  current_community = Community.find_by_domain(community)
  custom_field = FactoryGirl.build(:custom_dropdown_field, {
    :community_id => current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")]
  })

  if category_name
    category = find_category_by_name(category_name)
    custom_field.category_custom_fields.build(:category => category)
  else
    custom_field.category_custom_fields.build(:category => current_community.categories.first)
  end

  custom_field.options << options.hashes.map do |hash|
    en = FactoryGirl.build(:custom_field_option_title, :value => hash['fi'], :locale => 'fi')
    fi = FactoryGirl.build(:custom_field_option_title, :value => hash['en'], :locale => 'en')
    FactoryGirl.build(:custom_field_option, :titles => [en, fi])
  end

  custom_field.save!

  @custom_fields ||= []
  @custom_fields << custom_field
end

Given /^there is a custom text field "(.*?)" in community "(.*?)"(?: in category "([^"]*)")?$/ do |name, community, category_name|
  current_community = Community.find_by_domain(community)
  custom_field = FactoryGirl.build(:custom_text_field, {
    :community_id => current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")]
  })

  if category_name
    category = find_category_by_name(category_name)
    custom_field.category_custom_fields.build(:category => category)
  else
    custom_field.category_custom_fields.build(:category => current_community.categories.first)
  end

  custom_field.save!

  @custom_fields ||= []
  @custom_fields << custom_field
end

Given(/^there is a custom numeric field "(.*?)" in that community in category "(.*?)" with min value (\d+) and with max value (\d+)$/) do |name, category_name, min, max|
  custom_field = FactoryGirl.build(:custom_numeric_field, {
    :community_id => @current_community.id,
    :names => [CustomFieldName.create(:value => name, :locale => "en")],
    :min => min,
    :max => max
  })
  category = find_category_by_name(category_name)
  custom_field.category_custom_fields.build(:category => category)

  custom_field.save!

  @custom_fields ||= []
  @custom_fields << custom_field
end

Given(/^there is a custom date field "(.*?)" in that community in category "(.*?)"$/) do |name, category_name|
  custom_field = FactoryGirl.build(:custom_date_field, {
      :community_id => @current_community.id,
      :names => [CustomFieldName.create(:value => name, :locale => "en")]
  })
  category = find_category_by_name(category_name)
  custom_field.category_custom_fields.build(:category => category)

  custom_field.save!

  @custom_fields ||= []
  @custom_fields << custom_field
end

When /^I fill select custom date "(.*?)" with day="(.*?)", month="(.*?)" and year="(.*?)"$/ do |name,day,month,year|
  select_id_day="custom_fields_"+CustomFieldName.find_by_value(name).custom_field.id.to_s+"__3i"
  select_id_month="custom_fields_"+CustomFieldName.find_by_value(name).custom_field.id.to_s+"__2i"
  select_id_year="custom_fields_"+CustomFieldName.find_by_value(name).custom_field.id.to_s+"__1i"
  steps %Q{
    And I select "#{day}" from "#{select_id_day}"
    And I select "#{month}" from "#{select_id_month}"
    And I select "#{year}" from "#{select_id_year}"
  }
end

Then /^the option order for "(.*?)" should be following:$/ do |custom_field, table|
  table.hashes.each_cons(2).map do |two_hashes|
    first, second = two_hashes

    steps %Q{
      Then I should see "#{first['option']}" before "#{second['option']}"
    }
  end
end

When /^I click edit for custom field "(.*?)"$/ do |custom_field|
  find_edit_link_for_custom_field(custom_field).click()
end

When /^I click down for option "(.*?)"$/ do |option|
  page.execute_script("$(\"[value='#{option}']\")
    .closest(\".custom-field-option-locales\")
    .find(\".custom-fields-action-down\")
    .click()
  ");
end

When /^I click up for option "(.*?)"$/ do |option|
  page.execute_script("$(\"[value='#{option}']\")
    .closest(\".custom-field-option-locales\")
    .find(\".custom-fields-action-up\")
    .click()
  ");
end

When /^I move option "(.*?)" for "(.*?)" down (\d+) steps?$/ do |option, custom_field, n|
  steps %Q{
    When I click edit for custom field "#{custom_field}"
  }

  n.to_i.times do
    steps %Q{
      And I click down for option "#{option}"
    }
  end

  steps %Q{
    And I press submit
  }
end

When /^I move option "(.*?)" for "(.*?)" up (\d+) steps?$/ do |option, custom_field, n|
  steps %Q{
    When I click edit for custom field "#{custom_field}"
  }

  n.to_i.times do
    steps %Q{
      And I click up for option "#{option}"
    }
  end

  steps %Q{
    And I press submit
  }
end

When /^(?:|I )select "([^"]*)" from dropdown "([^"]*)"$/ do |value, field_name|
  field_id = find_custom_field_by_name(field_name).id
  select(value, :from => "custom_fields_#{field_id}")
end

When /^custom field "(.*?)" is not required$/ do |field_name|
  find_custom_field_by_name(field_name).update_attribute(:required, false)
end

When /^(?:|I )fill in text field "([^"]*)" with "([^"]*)"$/ do |field_name, value|
  field_id = find_custom_field_by_name(field_name).id
  fill_in("custom_fields_#{field_id}", :with => value)
end

When /^(?:|I )fill in custom numeric field "([^"]*)" with "([^"]*)"$/ do |field_name, value|
  field_id = find_custom_field_by_name(field_name).id
  fill_in("custom_fields_#{field_id}", :with => value)
end
