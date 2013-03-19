Given /^community "(.*?)" requires organization membership$/ do |community|
  c = Community.find_by_domain(community)
  c.settings.merge!({"require_organization_membership" => true})
  c.save!
end