LIST_SELECTOR = "#custom-fields-list"
REMOVE_SELECTOR = ".custom-fields-action-remove"
UP_SELECTOR = ".custom-fields-action-up"

module AdminSteps

  def find_row_for_custom_field(title)
    find(".custom-field-list-row", :text => "#{title}")
  end

  def find_remove_link_for_custom_field(title)
    find_row_for_custom_field(title).find(REMOVE_SELECTOR)
  end

  def find_up_link_for_custom_field(title)
    find_row_for_custom_field(title).find(UP_SELECTOR)
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
  steps %Q{
    Given I will confirm all following confirmation dialogs if I am running PhantomJS
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
    When I follow "Add new field"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[name_attributes][fi]" with "Talon tyyppi"
    And I toggle category "Spaces"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][en]" with "Room"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][fi]" with "Huone"
    And I fill in "custom_field[option_attributes][new-2][title_attributes][en]" with "Appartment"
    And I fill in "custom_field[option_attributes][new-2][title_attributes][fi]" with "Asunto"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][new-3][title_attributes][en]" with "House"
    And I fill in "custom_field[option_attributes][new-3][title_attributes][fi]" with "Talo"
    And I press submit
  }
end

When /^I add a new custom field "(.*?)" with invalid data$/ do |field_name|
  steps %Q{
    When I follow "Add new field"
    And I fill in "custom_field[name_attributes][en]" with "#{field_name}"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][en]" with "Room"
    And I fill in "custom_field[option_attributes][new-1][title_attributes][fi]" with "Huone"
    And I fill in "custom_field[option_attributes][new-2][title_attributes][en]" with "Appartment"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][new-3][title_attributes][en]" with "House"
    And I fill in "custom_field[option_attributes][new-3][title_attributes][fi]" with "Talo"
    And I press submit
  }
end

Given /^there is a custom field "(.*?)" in community "(.*?)"$/ do |name, community|
  current_community = Community.find_by_domain(community)
  @custom_field = FactoryGirl.build(:custom_field, :community_id => current_community.id)
  @custom_field.names << CustomFieldName.create(:value => name, :locale => "en")
  @custom_field.category_custom_fields.build(:category => current_community.categories.first)
  @custom_field.options << FactoryGirl.build(:custom_field_option)
  @custom_field.options << FactoryGirl.build(:custom_field_option)
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
    And I toggle category "#{@custom_field.community.categories.first.display_name}"
    And I toggle category "#{@custom_field.community.categories[1].display_name}"
    And I toggle category "#{@custom_field.community.categories[2].display_name}"
    And I press submit
  }
end

Then /^correct categories should be stored$/ do
  @custom_field.categories.should == [@custom_field.community.categories[1], @custom_field.community.categories[2]]
end  

When /^I try to remove all categories$/ do
  steps %Q{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I toggle category "#{@custom_field.categories.first.display_name}"
    And I press submit
  }
end

When /^I edit dropdown "(.*?)" options$/ do |field_name|
  steps %Q{
    When I follow "edit_custom_field_#{@custom_field.id}"
    And I fill in "custom_field[option_attributes][#{@custom_field.options[1].id}][title_attributes][en]" with "House2"
    And I fill in "custom_field[option_attributes][#{@custom_field.options[1].id}][title_attributes][fi]" with "Talo2"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][new-3][title_attributes][en]" with "House3"
    And I fill in "custom_field[option_attributes][new-3][title_attributes][fi]" with "Talo3"
    And I follow "custom-fields-add-option"
    And I fill in "custom_field[option_attributes][new-4][title_attributes][en]" with "House4"
    And I fill in "custom_field[option_attributes][new-4][title_attributes][fi]" with "Talo4"
    And I follow "remove-option-1"
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