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

Given /^"(.*?)" is an admin of the organization "(.*?)"$/ do |person_name, org_name|
  org = Organization.find_by_name!(org_name)
  person = Person.find_by_username!(person_name)
  m = OrganizationMembership.find_or_create_by_person_id_and_organization_id(person.id, org.id)
  m.update_attribute(:admin, true)
end

Then /^Most recently created organization should have all seller attributes filled$/ do
  o = Organization.last
  o.name.should_not be_blank
  o.company_id.should_not be_blank
  o.merchant_id.should_not be_blank
  o.merchant_key.should_not be_blank
end

When /^I click Osuuspankki logo$/ do
  page.find('input[src="https://payment.checkout.fi/static/img/osuuspankki.png"]').click
end

