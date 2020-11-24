Given(/^community "(.*?)" admin sent invitation to "(.*?)" code "(.*?)"$/) do |community, email, code|
  community = Community.where(ident: community).first
  FactoryGirl.create(:invitation, community: community, code: code, email: email)
end
