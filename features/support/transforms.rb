Transform /^author "(.*?)"$/ do |username|
  Person.find_by(username: username)
end

Transform /^starter "(.*?)"$/ do |username|
  Person.find_by(username: username)
end
