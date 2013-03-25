Given /^community "(.*?)" requires organization membership$/ do |community|
  c = Community.find_by_domain(community)
  c.settings.merge!({"require_organization_membership" => true})
  c.save!
end

Given /^there is an organization "(.*?)"(?: with email requirement "(.*?)")?$/ do |name, allowed_emails|
  FactoryGirl.create(:organization, :name => name, :allowed_emails => allowed_emails)
end