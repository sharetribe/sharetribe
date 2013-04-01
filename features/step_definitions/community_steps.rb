Given /^the test community has following available locales:$/ do |locale_table|
  @locales = []
  locale_table.hashes.each do |hash|
    @locales << hash['locale']
  end  
  
  #here is expected that the first community is the test community where the subdomain is pointing by default
  Community.first.update_attributes({:settings => { "locales" => @locales }})
end

Given /^the terms of community "([^"]*)" are changed to "([^"]*)"$/ do |community, terms|
  Community.find_by_domain(community).update_attribute(:consent, terms)
end

Then /^Most recently created user should be member of "([^"]*)" community with(?: status "(.*?)" and)? its latest consent accepted(?: with invitation code "([^"]*)")?$/ do |community_domain, status, invitation_code|
    # Person.last seemed to return unreliable results for some reason
    # (kassi_testperson1 instead of the actual newest person, so changed
    # to look for the latest CommunityMembership)
    status ||= "accepted"
    
    community = Community.find_by_domain(community_domain)
    CommunityMembership.last.community.should == community
    CommunityMembership.last.consent.should == community.consent
    CommunityMembership.last.status.should == status
    CommunityMembership.last.invitation.code.should == invitation_code if invitation_code.present?
end

Given /^given name and last name are not required in community "([^"]*)"$/ do |community|
  Community.find_by_domain(community).update_attribute(:real_name_required, 0)
end

Given /^community "([^"]*)" requires invite to join$/ do |community|
  Community.find_by_domain(community).update_attribute(:join_with_invite_only, true)
end

Given /^community "([^"]*)" requires users to have an email address of type "(.*?)"$/ do |community, email|
  Community.find_by_domain(community).update_attribute(:allowed_emails, email)
end

Given /^community "([^"]*)" has payments in use$/ do |community|
  Community.find_by_domain(community).update_attribute(:payments_in_use, true)
end

Given /^users can invite new users to join community "([^"]*)"$/ do |community|
  Community.find_by_domain(community).update_attribute(:users_can_invite_new_users, true)
end

Given /^there is an invitation for community "([^"]*)" with code "([^"]*)"(?: with (\d+) usages left)?$/ do |community, code, usages_left|
  inv = Invitation.new(:community => Community.find_by_domain(community), :code => code, :inviter_id => @people.first[1].id)
  inv.usages_left = usages_left if usages_left.present?
  inv.save
end

Then /^Invitation with code "([^"]*)" should have (\d+) usages_left$/ do |code, usages|
  Invitation.find_by_code(code).usages_left.should == usages.to_i
end

When /^I move to community "([^"]*)"$/ do |community|
  Capybara.default_host = "#{community}.lvh.me"
  Capybara.app_host = "http://#{community}.lvh.me:9887"
end

When /^I arrive to sign up page with the link in the invitation email with code "(.*?)"$/ do |code|
  visit "/en/signup?code=#{code}"
end

Given /^there is an existing community with "([^"]*)" in allowed emails and with slogan "([^"]*)"$/ do |email_ending, slogan|
  @existing_community = FactoryGirl.create(:community, :allowed_emails => email_ending, :slogan => slogan, :category => "company")
end

Given /^show me existing community$/ do
  puts "Email ending: #{@existing_community.allowed_emails}"
end

Then /^community "(.*?)" should require invite to join$/ do |community|
   Community.find_by_domain(community).join_with_invite_only.should be_true
end

Then /^community "(.*?)" should not require invite to join$/ do |community|
   Community.find_by_domain(community).join_with_invite_only.should_not be_true
end