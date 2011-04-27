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