# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#  listing_type = valid_st.keys[SecureRandom.random_number(valid_st.keys.length)]

CountryManager.create({
    given_name: "Country Manager Given Name",
    family_name: "Country Manager Family Name",
    email: "country@manager.com",
    country: "global",
    subject_line: "This subject will see requester",
    email_content: "This email will get the requester"
  }, :without_protection => true)
