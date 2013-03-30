Given /^community "(.*?)" requires organization membership$/ do |community|
  c = Community.find_by_domain(community)
  c.settings.merge!({"require_organization_membership" => true})
  c.save!
end

Given /^there is an organization "(.*?)"(?: with email requirement "(.*?)")?$/ do |name, allowed_emails|
  FactoryGirl.create(:organization, :name => name, :allowed_emails => allowed_emails)
end

Given /^"(.*?)" is member of organization that has registered as a seller$/ do |username|
  Person.find_by_username(username).organizations << FactoryGirl.create(:organization)
end

Given /^all listings of "(.*?)" are made with his first organization$/ do |username|
  p = Person.find_by_username(username)
  p.listings.each do |listing|
    listing.organization = p.organizations.first
    listing.save!
  end
end

Then /^Most recently created organization should have all seller attributes filled$/ do
  o = Organization.last
  o.name.should_not be_blank
  o.company_id.should_not be_blank
  o.merchant_id.should_not be_blank
  o.merchant_key.should_not be_blank
  
end