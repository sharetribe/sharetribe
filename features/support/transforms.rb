Transform /^author "(.*?)"$/ do |username|
  Person.find_by_username(username)
end

Transform /^starter "(.*?)"$/ do |username|
  Person.find_by_username(username)
end