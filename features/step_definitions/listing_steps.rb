Given /^there is a listing with title "([^"]*)"(?: from "([^"]*)")?(?: with category "([^"]*)")?(?: and with listing shape "([^"]*)")?(?: and it is valid "([^"]*)" days)?$/ do |title, author, category_name, shape_name, valid_days|
  opts = Hash.new
  opts[:title] = title
  opts[:category] = find_category_by_name(category_name) if category_name
  opts[:author] = Person.find_by(username: author) if author
  opts[:valid_until] = DateTime.current + valid_days.to_i.days if valid_days

  shape =
    if shape_name
      find_shape(name: shape_name)
    else
      all_shapes.first
    end

  create_listing(shape: shape, opts: opts)
end

Given /^the price of that listing is (\d+)\.(\d+) (EUR|USD)(?: per (.*?))?$/ do |price, price_decimal, currency, price_per|
  unit_type = if ["piece", "hour", "day", "night", "week", "month"].include?(price_per)
    price_per.to_sym
  else
    nil
  end

  @listing.update_attribute(:price, Money.new(price.to_i * 100 + price_decimal.to_i, currency))
  @listing.update_attribute(:unit_type, unit_type) unless unit_type.nil?
end

Given(/^that listing is free$/) do
  @listing.update_attribute(:price, nil)
end

Given /^that listing is closed$/ do
  @listing.update_attribute(:open, false)
end

When(/^I select "(.*?)" from listing type menu$/) do |title|
  expect(page).to have_css(".select", text: title)
  first('.select', text: title).click
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

Given /^that listing has a description "(.*?)"$/ do |description|
  @listing.update_attribute(:description, description)
end

When /^I save the listing$/ do
  steps %Q{
    And I press "Post listing"
  }
end

When /^I create a new listing "(.*?)" with price(?: "([^"]*)")?$/ do |title, price|
  price ||= "20"

  steps %Q{
    Given I am on the home page
    When I follow "new-listing-link"
    And I select "Items" from listing type menu
    And I select "Tools" from listing type menu
    And I select "Selling" from listing type menu
    And I fill in "listing_title" with "#{title}"
    And I fill in "listing_price" with "dsfsdf"
    And I press "Post listing"
    Then I should see "You need to insert a valid monetary value."
    When I fill in "listing_price" with "#{price}"
    And I save the listing
  }
end

When /^I choose to view only listing shape "(.*?)"$/ do |listing_shape|
  steps %Q{
    When I click "#home_toolbar-select-share-type"
    And I follow "#{listing_shape}" within ".home-toolbar-share-type-menu"
  }
end

Given /^there is a dropdown field "(.*?)" for category "(.*?)" in community "(.*?)" with options:$/ do |field_title, category_name, community_ident, opts_table|
  @community = Community.where(ident: community_ident).first
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

Given /^listing comments are in use in community "(.*?)"$/ do |community_ident|
  community = Community.where(ident: community_ident).first
  community.update_attribute(:listing_comments_in_use, true)
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

When(/^I select subcategory "(.*?)"$/) do |subcategory_name|
  expect(page).to have_content("Select subcategory")
  expect(page).to have_css(".select", text: subcategory_name)
  first(".select", text: subcategory_name).click
end

When(/^I set location to be New York/) do
  # Assume that GoogleMaps is not accessible and simulate that google maps has
  # set values to the appropriate hidden fields
  address = 'New York, NY, USA'
  latitude = '40.7127837'
  longitude = '-74.00594130000002'
  page.driver.execute_script(
    " $('#listing_origin_loc_attributes_address').val('#{address}');
      $('#listing_origin_loc_attributes_google_address').val('#{address}');
      $('#listing_origin_loc_attributes_latitude').val('#{latitude}');
      $('#listing_origin_loc_attributes_longitude').val('#{longitude}');
    "
  )
end

Then(/^I should see working hours form with changes$/) do
  expect(page).to have_css('.working-hours-form.has-changes')
end

Then(/^I should see working hours form without changes$/) do
  expect(page).to have_css('.working-hours-form.no-changes')
end

When(/^I add new working hours time slot for day "(.*?)"$/) do |day|
  within "#week-day-#{day}" do
    find('.addMore a').click
  end
end

Then(/^I should see working hours save button finished$/) do
  expect(page).to have_css('.working-hours-form .save-button.save-finished')
end

Given(/^that listing availability is booking$/) do
  @listing.update_attributes(availability: :booking, quantity_selector: 'number')
end

Given(/^that listing has default working hours$/) do
  @listing.working_hours_new_set
  @listing.save
end

Given(/^that listing have booking at "(.*?)" from "(.*?)" till "(.*?)"$/) do |date, from, till|
  start_time = "#{date} #{from}"
  end_time = "#{date} #{till}"
  community = Community.find(@listing.community_id)
  transaction = FactoryGirl.create(:transaction, community: community, listing: @listing, current_state: 'paid')
  FactoryGirl.create(:booking, tx: transaction, start_time: start_time, end_time: end_time, per_hour: true)
end

Then(/^(?:|I )should not see payment logos$/) do
  expect(page).not_to have_css('.submit-payment-form-link')
end

Then(/^(?:|I )should see payment logos$/) do
  expect(page).to have_css('.submit-payment-form-link')
end

