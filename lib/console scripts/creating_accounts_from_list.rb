# This script is used in Rails console, when need to create large number of user 
# accounts based on a list/array

# Designed to work only without ASI.

community_id = 1
accounts ||= [] # set this before to be array of arrays (format: [given_name, family_name, description, email])
initial_locale = "es"

accounts.each do |acc|
  pass = ApplicationHelper.random_sting(8)
  
  # create the user
  p = Person.new 
  p.locale = initial_locale
  p.given_name = acc[0]
  p.family_name = acc[1]
  #p.description = acc[2] # Skip description, to displayt the reminderto people to add their details
  p.email = acc[3]
  p.username = acc[3][/^[^@]+/,0].gsub(".", "_")
  p.password = pass
  p.confirmed_at = Time.now
  p.set_default_preferences
  p.test_group_number = 1 + rand(4)
  p.active = 0 # Create inactive users so they don't receive mails if they never log in
  p.save!
  
  # join the community
  membership = CommunityMembership.new(:person => p, :community_id => community_id, :consent => "automatically_reated_account", :status => "accepted")
  membership.save!
  
  # email the user
  PersonMailer.automatic_account_created(p,pass).deliver
  print "."; STDOUT.flush
end


