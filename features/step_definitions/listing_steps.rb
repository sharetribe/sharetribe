Given /^there is a listing with title "([^"]*)"(?: from "([^"]*)")?(?: with category "([^"]*)")?(?: and with transaction type "([^"]*)")?$/ do |title, author, category_name, transaction_type|
  opts = Hash.new
  opts[:title] = title
  opts[:category] = find_category_by_name(category_name) if category_name
  opts[:transaction_type] = find_transaction_type_by_name(transaction_type) if transaction_type
  opts[:author] = Person.find_by_username(author) if author
  opts[:communities] = [@current_community]

  @listing = FactoryGirl.create(:listing, opts)
end

Given /^there is rideshare (offer|request) from "([^"]*)" to "([^"]*)" by "([^"]*)"$/ do |type, origin, destination, author|
  pending
  puts "WARNING! Using deprecated step"
  puts "This step maps old deprecated step to new one. You shouldn't use this anymore"

  new_category = "Services"

  transaction_type = if type == "offer" then
    "Selling services"
  else
    "Requesting"
  end

  author_step = if author
    " from \"#{author}\""
  else
    ""
  end

  community ||= "test"

  title = "#{origin} - #{destination}"

  puts %Q{Given there is a listing with title "#{title}"#{author_step} with category "#{new_category}" and with transaction type "#{transaction_type}" in community "#{community}"}

  steps %Q{
    Given there is a listing with title "#{title}"#{author_step} with category "#{new_category}" and with transaction type "#{transaction_type}" in community "#{community}"
  }
end

Given /^there is (item|favor|housing) (offer|request) with title "([^"]*)"(?: from "([^"]*)")?(?: and with share type "([^"]*)")?(?: and with price "([^"]*)")?$/ do |category, type, title, author, share_type, price|
  pending
  puts "WARNING! Using deprecated step"
  puts "This step maps old deprecated step to new one. You shouldn't use this anymore"

  new_category = case category
  when "item"
    "Items"
  when "favor"
    "Services"
  when "housing"
    "Spaces"
  end

  transaction_type = if share_type.present?
    transaction_type = if share_type == "sell" then "Selling"
    elsif share_type == "borrow" then "Requesting"
    elsif share_type == "offer" then "Selling services"
    elsif share_type == "lend" then "Lending"
    else
      "Requesting"
    end
  else
    if type == "offer" then
      "Selling services"
    else
      "Requesting"
    end
  end

  author_step = if author
    " from \"#{author}\""
  else
    ""
  end

  community ||= "test"

  steps %Q{
    Given there is a listing with title "#{title}"#{author_step} with category "#{new_category}" and with transaction type "#{transaction_type}" in community "#{community}"
  }

  puts %Q{Given there is a listing with title "#{title}"#{author_step} with category "#{new_category}" and with transaction type "#{transaction_type}" in community "#{community}"}

  if price
    @listing.update_attribute(:price, price) 
  end
  
end

Given /^that listing is closed$/ do
  @listing.update_attribute(:open, false)
end

Given /^visibility of that listing is "([^"]*)"$/ do |visibility|
  @listing.update_attribute(:visibility, visibility)
end

Given /^privacy of that listing is "([^"]*)"$/ do |privacy|
  @listing.update_attribute(:privacy, privacy)
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

When /^I create a new listing "([^"]*)" with price$/ do |title|
  steps %Q{
    Given I am on the home page
    When I follow "new-listing-link"
    And I follow "Items"
    And I follow "Tools" within "#option-groups"
    And I follow "Selling"
    And I fill in "listing_title" with "#{title}"
    And I fill in "listing_price" with "dsfsdf"
    And I press "Save listing"
    Then I should see "Price must be a whole number."
    When I fill in "listing_price" with "20"
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
  @category = Category.find_by_name(category_name)
  @custom_field = FactoryGirl.build(:custom_dropdown_field, :community => @community)
  @custom_field.category_custom_fields << FactoryGirl.build(:category_custom_field, :category => @category, :custom_field => @custom_field)
  @custom_field.names << CustomFieldName.create(:value => field_title, :locale => "en")
  
  opts_table.hashes.each do |hash|
    title = CustomFieldOptionTitle.create(:value => hash[:title], :locale => "en")
    option = FactoryGirl.build(:custom_field_option, :titles => [title])
    @custom_field.options << option
  end

  @custom_field.save!
end


Given /^that listing has custom field "(.*?)" with value "(.*?)"$/ do |field_title, option_title|
  field = CustomFieldName.find_by_value!(field_title).custom_field
  option = CustomFieldOptionTitle.find_by_value!(option_title).custom_field_option
  value = FactoryGirl.build(:custom_field_value, :listing => @listing, :question => field)
  selection = CustomFieldOptionSelection.create!(:custom_field_value => value, :custom_field_option => option)
  value.custom_field_option_selections << selection
  value.save!
end

Given /^listing comments are in use in community "(.*?)"$/ do |community_domain|
  community = Community.find_by_domain(community_domain)
  community.update_attribute(:listing_comments_in_use, true)
end