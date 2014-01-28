Then /^I should see that there is a (top level category|subcategory) "(.*?)"$/ do |category_type, category_name|
  steps %Q{
    Then I should see "#{category_name}" within "##{category_type.tr(" ", "-")}-#{category_name.downcase}"
  }
end

When /^I add a new category "(.*?)"$/ do |category_name|
  steps %Q{
    When I follow "+ Create a new category"
    And I fill in "category[translation_attributes][en][name]" with "#{category_name}"
    And I fill in "category[translation_attributes][fi][name]" with "Testinimi"
    And I press submit
  }
end