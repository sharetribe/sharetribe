Given(/^a logged in user "(.*?)"$/) do |username|
  create_person(username)
  login_user_without_browser(username)
end
