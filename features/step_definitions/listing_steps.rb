Given /^there is a listing with title "([^"]*)"(?: from "([^"]*)")?(?: with category "([^"]*)")?(?: and with transaction type "([^"]*)")?$/ do |title, author, category_name, transaction_type|
  opts = Hash.new
  opts[:title] = title
  opts[:category] = find_category_by_name(category_name) if category_name
  opts[:transaction_type] = find_transaction_type_by_name(transaction_type) if transaction_type
  opts[:author] = Person.find_by_username(author) if author

  create_listing_to_current_community(opts)
end

Given /^the price of that listing is (\d+)\.(\d+) (EUR|USD)$/ do |price, price_decimal, currency|
  @listing.update_attribute(:price, Money.new(price.to_i * 100 + price_decimal.to_i, currency))
end

Given /^that listing is closed$/ do
  @listing.update_attribute(:open, false)
end

Given(/^that listing has a numeric answer "(.*?)" for "(.*?)"$/) do |answer, custom_field|
  numeric_custom_field = find_numeric_custom_field_type_by_name(custom_field)
  FactoryGirl.create(:custom_numeric_field_value, listing: @listing, numeric_value: answer, question: numeric_custom_field)
end

When(/^I set search range for "(.*?)" between "(.*?)" and "(.*?)"$/) do |selector, min, max|
  page.execute_script("$('#{selector}').val([#{min.to_f}, #{max.to_f}])");
end

When(/^I set price range between "(.*?)" and "(.*?)"$/) do |min, max|
  steps %Q{
    When I set search range for "#range-slider-price" between "#{min}" and "#{max}"
  }
end

When(/^I set search range for numeric filter "(.*?)" between "(.*?)" and "(.*?)"$/) do |custom_field, min, max|
  numeric_custom_field = find_numeric_custom_field_type_by_name(custom_field)
  selector = "#range-slider-#{numeric_custom_field.id}"

  steps %Q{
    When I set search range for "#{selector}" between "#{min}" and "#{max}"
  }
end

Given /^visibility of that listing is "([^"]*)"$/ do |visibility|
  @listing.update_attribute(:visibility, visibility)
end

Given /^privacy of that listing is "([^"]*)"$/ do |privacy|
  @listing.update_attribute(:privacy, privacy)
end

Given(/^that listing belongs to community "(.*?)"$/) do |domain|
  @listing.communities = [Community.find_by_domain(domain)]
end

Given /^that listing is visible to members of community "([^"]*)"$/ do |domain|
  @listing.communities << Community.find_by_domain(domain)
end

Given /^that listing has a description "(.*?)"$/ do |description|
  @listing.update_attribute(:description, description)
end

Then /^There should be a rideshare (offer|request) from "([^"]*)" to "([^"]*)" starting at "([^"]*)"$/ do |share_type, origin, destination, time|
  listings = Listing.find_all_by_title("#{origin} - #{destination}")
end

When /^there is one comment to the listing from "([^"]*)"$/ do |author|
  @comment = FactoryGirl.create(:comment, :listing => @listing, :author => @people[author])
end

Then /^the total number of comments should be (\d+)$/ do |no_of_comments|
  Comment.all.count.should == no_of_comments.to_i
end

When /^I save the listing$/ do
  steps %Q{
    And I press "Save listing"
  }
end

When /^I create a new listing "(.*?)" with price(?: "([^"]*)")?$/ do |title, price|
  price ||= "20"

  steps %Q{
    Given I am on the home page
    When I follow "new-listing-link"
    And I follow "Items"
    And I follow "Tools" within "#option-groups"
    And I follow "Selling"
    And I fill in "listing_title" with "#{title}"
    And I fill in "listing_price" with "dsfsdf"
    And I press "Save listing"
    Then I should see "You need to insert a valid monetary value."
    When I fill in "listing_price" with "#{price}"
    And I save the listing
  }
end

When /^I select that I want to sell housing$/ do
  steps %Q{
    And I follow "I have something to offer"
    And I follow "A space"
    And I follow "I'm selling it"
    Then I should see "Space you offer"
  }
end

When /^I fill in listing form with housing information$/ do
  steps %Q{
    And I fill in "listing_title" with "Nice appartment in the city centre"
    And I fill in "listing_price" with "10000"
  }
end

When /^I choose to view only share type "(.*?)"$/ do |share_type_name|
  puts "Using deprecated step When I choose to view only share type"
  steps %Q{
    When I click "#home_toolbar-select-share-type"
    And I follow "#{share_type_name}" within ".home-toolbar-share-type-menu"
  }
end

When /^I choose to view only transaction type "(.*?)"$/ do |transaction_type|
  steps %Q{
    When I click "#home_toolbar-select-share-type"
    And I follow "#{transaction_type}" within ".home-toolbar-share-type-menu"
  }
end

Given /^there is a dropdown field "(.*?)" for category "(.*?)" in community "(.*?)" with options:$/ do |field_title, category_name, community_domain, opts_table|
  @community = Community.find_by_domain(community_domain)
  @category = find_category_by_name(category_name)
  @custom_field = FactoryGirl.build(:custom_dropdown_field, :community => @community, :names => [CustomFieldName.create(:value => field_title, :locale => "en")])
  @custom_field.category_custom_fields << FactoryGirl.build(:category_custom_field, :category => @category, :custom_field => @custom_field)

  opts_table.hashes.each do |hash|
    title = CustomFieldOptionTitle.create(:value => hash[:title], :locale => "en")
    option = FactoryGirl.build(:custom_field_option, :titles => [title])
    @custom_field.options << option
  end

  @custom_field.save!
end

Given(/^there is a custom checkbox field "(.*?)" in that community in category "(.*?)" with options:$/) do |field_title, category_name, opts_table|
  @category = find_category_by_name(category_name)
  @custom_field = FactoryGirl.build(:custom_checkbox_field, :community => @current_community, :names => [CustomFieldName.create(:value => field_title, :locale => "en")])
  @custom_field.category_custom_fields << FactoryGirl.build(:category_custom_field, :category => @category, :custom_field => @custom_field)

  opts_table.hashes.each do |hash|
    title = CustomFieldOptionTitle.create(:value => hash[:title], :locale => "en")
    option = FactoryGirl.build(:custom_field_option, :titles => [title])
    @custom_field.options << option
  end

  @custom_field.save!
end

Given(/^that listing has a checkbox answer "(.*?)" for "(.*?)"$/) do |option_title, field_title|
  field = CustomFieldName.find_by_value!(field_title).custom_field
  option = CustomFieldOptionTitle.find_by_value!(option_title).custom_field_option
  value = FactoryGirl.build(:checkbox_field_value, :listing => @listing, :question => field)
  selection = CustomFieldOptionSelection.create!(:custom_field_value => value, :custom_field_option => option)
  value.custom_field_option_selections << selection
  value.save!
end

Given /^that listing has custom field "(.*?)" with value "(.*?)"$/ do |field_title, option_title|
  field = CustomFieldName.find_by_value!(field_title).custom_field
  option = CustomFieldOptionTitle.find_by_value!(option_title).custom_field_option
  selection = CustomFieldOptionSelection.create!(:custom_field_option => option)
  value = FactoryGirl.build(:dropdown_field_value, :listing => @listing, :question => field, :custom_field_option_selections => [selection])
  value.save!
end

Given /^listing comments are in use in community "(.*?)"$/ do |community_domain|
  community = Community.find_by_domain(community_domain)
  community.update_attribute(:listing_comments_in_use, true)
end

When(/^I remove the image$/) do

  # Hovering didn't work without first clicking the element. Not sure why, but I expect that it has something to do
  # with window focus
  steps %Q{
    And I click ".fileupload-preview"
    When I hover ".fileupload-preview"
    And I click ".fileupload-preview-remove-image"
    Then I should see "Select file"
  }
end

When(/^I click for the next image$/) do
  # Selenium can not interact with hidden elements
  page.execute_script("$('#listing-image-navi-right').show()");
  find("#listing-image-navi-right", visible: false).click
end

When(/^I click for the previous image$/) do
  # Selenium can not interact with hidden elements
  page.execute_script("$('#listing-image-navi-right').show()");
  find("#listing-image-navi-left", visible: false).click
end

Then(/^I should see that the listing has "(.*?)"$/) do |option_title|
  find(".checkbox-option.selected", :text => option_title)
end

Then(/^I should see that the listing does not have "(.*?)"$/) do |option_title|
  find(".checkbox-option.not-selected", :text => option_title)
end

# Move to more generic place if needed
def select_date_from_date_selector(date, date_selector_base_id)
  day = date.day
  month = I18n.t("date.month_names")[date.month]
  year = date.year

  select(day, :from => "#{date_selector_base_id}_3i")
  select(month, :from => "#{date_selector_base_id}_2i")
  select(year, :from => "#{date_selector_base_id}_1i")
end

def select_start_date(date)
  date = [date.year, date.month, date.day].join("-")
  page.execute_script("$('#start-on').val('#{date}')");
  # Selenium can not interact with hidden elements, use JavaScript
  page.execute_script("$('#booking-start-output').val('#{date}')");
end

def select_end_date(date)
  date = [date.year, date.month, date.day].join("-")
  page.execute_script("$('#end-on').val('#{date}')");
  # Selenium can not interact with hidden elements, use JavaScript
  page.execute_script("$('#booking-end-output').val('#{date}')");
end

When(/^I set the expiration date to (\d+) months from now$/) do |months|
  select_date_from_date_selector(months.to_i.months.from_now, "listing_valid_until")
end

When(/^I (?:buy) that listing$/) do
  visit(path_to "the listing page")
  find(".book-button").click
end

When(/^I select category "(.*?)"$/) do |category_name|
  page.should have_content("Select category")
  click_link(category_name)
end

When(/^I select subcategory "(.*?)"$/) do |subcategory_name|
  page.should have_content("Select subcategory")
  click_link(subcategory_name)
end

When(/^I select transaction type "(.*?)"$/) do |transaction_type_name|
  page.should have_content("Select listing type")
  click_link(transaction_type_name)
end

Then(/^I should see the new listing form$/) do
  page.should have_content("Listing title")
  page.should have_content("Detailed description")
  page.should have_content("Image")
end

Then(/^I should warning about missing payment details$/) do
  page.should have_content("You need to fill in payout details before you can post a listing. Go to payment settings to fill in the details.")
end

When(/^I make a booking request for that listing for (\d+) days$/) do |day_count|
  visit_current_listing
  select_days_from_now(day_count)

  click_button('Buy')
end

When(/I fill rent time for (\d+) days$/) do |day_count|
  select_days_from_now(day_count)
end

def select_days_from_now(day_count)
  @booking_end_date = Date.today + day_count.to_i.days - 1.day
  select_start_date(Date.today)
  select_end_date(@booking_end_date)
end
