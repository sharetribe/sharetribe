Then /^I should see that there is a (top level category|subcategory) "(.*?)"$/ do |category_type, category_name|
  steps %Q{
    Then I should see "#{category_name}" within "##{category_type.tr(" ", "-")}-#{category_name.downcase}"
  }
end

When /^I add a new category "(.*?)"(?: under category "([^"]*)")?$/ do |category_name, parent_category_name|
  steps %Q{
    When I follow "+ Create a new category"
    And I fill in "category[translation_attributes][en][name]" with "#{category_name}"
    And I fill in "category[translation_attributes][fi][name]" with "Testinimi"
  }
  if parent_category_name
    steps %Q{
      And I select "#{parent_category_name}" from "category_parent_id"
    }
  end
  steps %Q{
    And I press submit
  }
end

When /^I add a new category "(.*?)" with invalid data$/ do |category_name|
  steps %Q{
    When I follow "+ Create a new category"
    And I fill in "category[translation_attributes][en][name]" with "#{category_name}"
    And I toggle transaction type "Selling"
    And I toggle transaction type "Lending"
    And I press submit
  }
end

When /^I toggle transaction type "([^"]*)"$/ do |transaction_type_label|
  find(:css, "label", :text => transaction_type_label).click
end