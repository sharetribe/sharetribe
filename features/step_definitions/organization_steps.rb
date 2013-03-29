Given /^community "(.*?)" requires organization membership$/ do |community|
  c = Community.find_by_domain(community)
  c.settings.merge!({"require_organization_membership" => true})
  c.save!
end

Given /^there is an organization "(.*?)"(?: with email requirement "(.*?)")?$/ do |name, allowed_emails|
  FactoryGirl.create(:organization, :name => name, :allowed_emails => allowed_emails)
end

Then /^Most recently created organization should have all seller attributes filled$/ do
  o = Organization.last
  o.name.should_not be_blank
  o.company_id.should_not be_blank
  o.merchant_id.should_not be_blank
  o.merchant_key.should_not be_blank
  
end