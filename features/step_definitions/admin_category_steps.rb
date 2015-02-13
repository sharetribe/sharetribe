module AdminCategorySteps
  DELETE_LINK_SELECTOR = ".category-action-remove"
  UP_LINK_SELECTOR = ".category-action-up"
  DOWN_LINK_SELECTOR = ".category-action-down"

  def find_category_row(category_name)
    find(".category-row", :text => "#{category_name}")
  end

  def find_remove_link_for_category(category_name)
    find_category_row(category_name).find(DELETE_LINK_SELECTOR)
  end

  def find_up_link_for_category(category_name)
    find_category_row(category_name).find(UP_LINK_SELECTOR)
  end

  def find_down_link_for_category(category_name)
    find_category_row(category_name).find(DOWN_LINK_SELECTOR)
  end

  def should_not_find_remove_link_for_category(category_name)
    find_category_row(category_name).should have_no_selector(DELETE_LINK_SELECTOR)
  end

  def find_category_by_name(category_name)
    Category.all.inject("") do |memo, c|
      memo = c if c.display_name("en").eql?(category_name) && c.community_id == @current_community.id
      memo
    end
  end

  def find_transaction_type_by_name(transaction_type_name)
    TransactionType.all.inject("") do |memo, tt|
      memo = tt if tt.display_name("en").eql?(transaction_type_name) && tt.community_id == @current_community.id
      memo
    end
  end

end

World(AdminCategorySteps)

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
    And I deselect all transaction types
    And I press submit
  }
end

When /^I deselect all transaction types$/ do
  page.all(:css, ".category-transaction-type-checkbox").each do |checkbox|
    checkbox.set(false)
  end
end

When /^I remove category "(.*?)"$/ do |category_name|
  steps %Q{
    Given I will confirm all following confirmation dialogs in this page if I am running PhantomJS
  }

  find_remove_link_for_category(category_name).click

  steps %Q{
    And I confirm alert popup
  }
end

When /^I remove category "(.*?)" which needs confirmation$/ do |category_name|
  find_remove_link_for_category(category_name).click
end

Then /^the category "(.*?)" should be removed$/ do |category_name|
  steps %Q{
    Then I should not see "#{category_name}" within "#categories-list"
  }
end

Then /^I should see warning about the removal of subcategory "(.*?)"$/ do |category_name|
  steps %Q{
    Then I should see "Warning!"
    Then I should see "subcategories in the category. They will be removed."
  }
end

When /^I confirm category removal$/ do
  steps %Q{
    When I press submit
  }
end

Given /^"(.*?)" is the only top level category in community "(.*?)"$/ do |category_name, community|
  community = Community.find_by_name(community)
  category = find_category_by_name(category_name)
  community.main_categories.each do |community_category|
    if !community_category.eql? category then community_category.destroy end
  end
end

Then /^I should not be able to remove category "(.*?)"$/ do |category_name|
  should_not_find_remove_link_for_category(category_name)
end

Then /^I should be able to select new category for listing "(.*?)"$/ do |arg1|
  find("#new_category").should be_visible
end

When /^I select "(.*?)" as a new category$/ do |new_category_name|
  steps %Q{
    When I select "#{new_category_name}" from "new_category"
  }
end

Then /^the listing "(.*?)" should belong to category "(.*?)"$/ do |listing_title, category_name|
  listing = Listing.find_by_title(listing_title)
  listing.category.translations.any? { |t| t.name == category_name }
end

Then /^the category order should be following:$/ do |table|
  table.hashes.each_cons(2).map do |two_hashes|
    first, second = two_hashes

    steps %Q{
      Then I should see "#{first['category']}" before "#{second['category']}"
    }
  end
end

When /^I move category "(.*?)" down (\d+) steps?$/ do |category, n|
  n.to_i.times do
    steps %Q{
      When I click down for category "#{category}"
    }
  end
end

When /^I move category "(.*?)" up (\d+) steps?$/ do |category, n|
  n.to_i.times do
    steps %Q{
      When I click up for category "#{category}"
    }
  end
end

When /^I click down for category "(.*?)"$/ do |category|
  find_down_link_for_category(category).click()
end

When /^I click up for category "(.*?)"$/ do |category|
  find_up_link_for_category(category).click()
end

When(/^I change category "(.*?)" name to "(.*?)"$/) do |old_name, new_name|
  category = find_category_by_name(old_name)
  steps %Q{
    When I follow "edit_category_#{category.id}"
    And I fill in "category[translation_attributes][en][name]" with "#{new_name}"
    And I press submit
  }
end

When(/^I change parent of category "(.*?)" to "(.*?)"$/) do |child_name, parent_name|
  category = find_category_by_name(child_name)
  steps %Q{
    When I follow "edit_category_#{category.id}"
    And I select "#{parent_name}" from "category_parent_id"
    And I press submit
  }
end

When(/^I try to edit category "(.*?)"$/) do |category_name|
  category = find_category_by_name(category_name)
  steps %Q{
    When I follow "edit_category_#{category.id}"
  }
end

Given(/^category "(.*?)" should have the following transaction types:$/) do |category_name, transaction_types|
  category = find_category_by_name(category_name)
  tt_array = transaction_types.hashes.inject([]) do |memo, hash|
    memo << hash['transaction_type']
    memo
  end
  category_tt_array = category.transaction_types.collect { |tt| tt.display_name("en") }
  tt_array.uniq.sort.should == category_tt_array.uniq.sort
end

When(/^I change transaction types of category "(.*?)" to following:$/) do |category_name, new_transaction_types|
  category = find_category_by_name(category_name)
  steps %Q{
    When I follow "edit_category_#{category.id}"
    And I deselect all transaction types
  }
  new_transaction_types.hashes.each do |hash|
    steps %Q{
      And I toggle transaction type "#{hash['transaction_type']}"
    }
  end
  steps %Q{
    And I press submit
  }
end

When /^I toggle transaction type "(.*?)"$/ do |transaction_type_name|
  transaction_type = find_transaction_type_by_name(transaction_type_name)
  find(:css, "#transaction_type_checkbox_#{transaction_type.id}").click
end

When /^I try to remove all transaction types from category "(.*?)"$/ do |category_name|
  category = find_category_by_name(category_name)
  steps %Q{
    When I follow "edit_category_#{category.id}"
    And I deselect all transaction types
    And I press submit
  }
end
