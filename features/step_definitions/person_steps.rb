Given(/^a user "(.*?)"$/) do |username|
  person = FactoryGirl.create(:person, username: username)
  membership = FactoryGirl.create(:community_membership, person: person, community: @current_community)
end