Given(/^community "(.*?)" admin sent invitation to "(.*?)" code "(.*?)"$/) do |community, email, code|
  community = Community.where(ident: community).first
  FactoryBot.create(:invitation, community: community, code: code, email: email)
end
