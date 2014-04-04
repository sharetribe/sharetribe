When /^news are enabled in community "([^"]*)"$/ do |domain|
  Community.find_by_domain(domain).update_attribute(:news_enabled, true)
end

When /^anyone can add news items in community "([^"]*)"$/ do |domain|
  Community.find_by_domain(domain).update_attribute(:all_users_can_add_news, true)
end

Given /^there is news item by "([^"]*)" in community "([^"]*)"$/ do |author, community|
  @news_item = FactoryGirl.create(:news_item, :author => @people[author], :community => Community.find_by_domain(community))
end

When /^there are "([^"]*)" news items in community "([^"]*)"$/ do |amount, community|
  amount.to_i.times do
    @news_item = FactoryGirl.create(:news_item, :community => Community.find_by_domain(community))
  end
end
