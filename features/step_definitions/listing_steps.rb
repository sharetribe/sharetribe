Given /^there is (item|favor|housing) (offer|request) with title "([^"]*)"(?: from "([^"]*)")?(?: and with share type "([^"]*)")?(?: and with price "([^"]*)")?$/ do |category, type, title, author, share_type, price|
  share_type ||= type
  @listing = FactoryGirl.create(:listing, 
                               :category => find_or_create_category(category),
                               :title => title,
                               :share_type => find_or_create_share_type(share_type),
                               :author => (@people && @people[author] ? @people[author] : Person.first),
                               :communities => [Community.find_by_domain("test")],
                               :privacy => "public"
                               )
  if price
    @listing.update_attribute(:price, price) 
  end
  
end

Given /^there is rideshare (offer|request) from "([^"]*)" to "([^"]*)" by "([^"]*)"$/ do |type, origin, destination, author|
  @listing = FactoryGirl.create(:listing,
                               :category => find_or_create_category("rideshare"),
                               :origin => origin,
                               :destination => destination,
                               :author => @people[author],
                               :communities => [Community.find_by_domain("test")],
                               :share_type => find_or_create_share_type(type),
                               :privacy => "public"
                               )
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

Then /^There should be a rideshare (offer|request) from "([^"]*)" to "([^"]*)" starting at "([^"]*)"$/ do |share_type, origin, destination, time|
  listings = Listing.find_all_by_title("#{origin} - #{destination}")
end

When /^there is one comment to the listing from "([^"]*)"$/ do |author|
  @comment = FactoryGirl.create(:comment, :listing => @listing, :author => @people[author])
end

Then /^the total number of comments should be (\d+)$/ do |no_of_comments|
  Comment.all.count.should == no_of_comments.to_i
end

When /^there are some custom categories$/ do
  community = Community.first
  parent_share_type = ShareType.find_by_name("request")
  parent_category = Category.find_by_name("item")
  top_category = Category.create(:name => "wood", :icon => "other")
  child_category = Category.create(:name => "doll", :icon => "other", :parent_id => parent_category.id)
  child_category2 = Category.create(:name => "record", :icon => "other", :parent_id => parent_category.id)
  child_category3 = Category.create(:name => "bottle", :icon => "other", :parent_id => parent_category.id)
  child_share_type = ShareType.create(:name => "lost", :icon => "other", :parent_id => parent_share_type.id)
  child_share_type2 = ShareType.create(:name => "found", :icon => "other", :parent_id => parent_share_type.id)
  
  CommunityCategory.create(:category_id => parent_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:category_id => top_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:category_id => top_category.id, :share_type_id => child_share_type.id)
  CommunityCategory.create(:category_id => top_category.id, :share_type_id => child_share_type2.id)
  CommunityCategory.create(:category_id => child_category.id)
  CommunityCategory.create(:category_id => child_category2.id)
  CommunityCategory.create(:category_id => child_category3.id)
end

When /^all categories are custom categories$/ do
  CategoriesHelper.remove_all_categories_from_db
  community = Community.first
  parent_share_type = ShareType.create(:name => "offer", :icon => "offer")
  parent_category = Category.create(:name => "plastic", :icon => "other")
  top_category = Category.create(:name => "wood", :icon => "other")
  child_category = Category.create(:name => "doll", :icon => "other", :parent_id => parent_category.id)
  child_category2 = Category.create(:name => "record", :icon => "other", :parent_id => parent_category.id)
  child_category3 = Category.create(:name => "bottle", :icon => "other", :parent_id => parent_category.id)
  child_share_type = ShareType.create(:name => "lost", :icon => "other", :parent_id => parent_share_type.id)
  child_share_type2 = ShareType.create(:name => "found", :icon => "other", :parent_id => parent_share_type.id)
  
  CommunityCategory.create(:community_id => community.id, :category_id => parent_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:community_id => community.id, :category_id => top_category.id, :share_type_id => parent_share_type.id)
  CommunityCategory.create(:community_id => community.id, :category_id => top_category.id, :share_type_id => child_share_type.id)
  CommunityCategory.create(:community_id => community.id, :category_id => top_category.id, :share_type_id => child_share_type2.id)
  CommunityCategory.create(:community_id => community.id, :category_id => child_category.id)
  CommunityCategory.create(:community_id => community.id, :category_id => child_category2.id)
  CommunityCategory.create(:community_id => community.id, :category_id => child_category3.id)
end

Then /^add default categories back$/ do
  reset_categories_to_default
end