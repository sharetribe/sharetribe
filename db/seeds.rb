# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
#  listing_type = valid_st.keys[SecureRandom.random_number(valid_st.keys.length)]

Person.all.each { |p| p.set_default_preferences }

user = Person.first
for i in 1..20
  listing_type = Listing::VALID_TYPES[SecureRandom.random_number(2)]
  category = Listing::VALID_CATEGORIES[SecureRandom.random_number(4)]
  valid_until = DateTime.now + 1.month
  listing = user.create_listing(:listing_type => listing_type, :category => category, :valid_until => valid_until, :title => "#{listing_type} - #{category} - test#{i}", :description => "Test #{listing_type} #{category}")
  
  if(category.eql? "rideshare")
    origin_lat = SecureRandom.random_number() * 0.15 + 60.15
    origin_lng = SecureRandom.random_number() * 0.5 + 24.70
    listing.build_origin_loc(:latitude => origin_lat, :longitude => origin_lng)
    dest_lat = SecureRandom.random_number() * 0.15 + 60.15
    dest_lng = SecureRandom.random_number() * 0.5 + 24.70
    listing.build_destination_loc(:latitude => dest_lat, :longitude => dest_lng)
    listing.origin = "Origin #{i}"
    listing.destination = "Destination #{i}"
  else
    lat = SecureRandom.random_number() * 0.15 + 60.15
    lng = SecureRandom.random_number() * 0.5 + 24.70
    listing.build_location(:latitude => lat, :longitude => lng)
  end
  
  if(Listing::VALID_SHARE_TYPES[listing_type][category])
    share_type = Listing::VALID_SHARE_TYPES[listing_type][category][SecureRandom.random_number(Listing::VALID_SHARE_TYPES[listing_type][category].length)]
  else
    share_type = []
  end
  listing.share_types.build(:name => share_type)
  listing.save
end
