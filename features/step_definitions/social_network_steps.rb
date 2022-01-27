Given(/^provider "(.*?)" is mocked$/) do |provider|
  oauth_mock(provider)
end

Given(/^community "(.*?)" has facebook app configured$/) do |ident|
  Community.find_by_ident(ident).update!(
    facebook_connect_id: "123456789012345",
    facebook_connect_secret: "abcdef0123456789abcdef0123456789",
    facebook_connect_enabled: true
  )
end
