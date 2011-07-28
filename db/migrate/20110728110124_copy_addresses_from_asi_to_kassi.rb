class CopyAddressesFromAsiToKassi < ActiveRecord::Migration
  def self.up
    say "It is RECOMMENDED to change the 'set_property :delta => true' to false in listing.rb before running this migration, since delta indexing makes it really slow if there are lot of listings."
    say "Just remember to turn it back on afterwards!", true
        
    say "NOTE: if you have more than 2500 addresses in the ASI database this migration might fail, due Google maps API usage limits."
    Person.all.each do |person|
      address = person.unstructured_address
      unless address.blank? || address == "Not found!"
        location = Location.new
        location.location_type = "person"
        location.address = address
        resp = location.search_and_fill_latlng
        if resp
          puts "Coordinates found for #{address}"
          location.google_address = address
          
          # Set the same location to all the listings that person has
          person.listings.each do |listing|
            unless listing.category == "rideshare" #can't guess a good default for rideshares
              loc = Location.new( :address => location.address, 
                                  :google_address => location.google_address,
                                  :latitude  => location.latitude,
                                  :longitude => location.longitude,
                                  :location_type => "origin_loc")
              loc.save
              listing.location = loc
              listing.save
              puts "Listing's (#{listing.title})location is now: #{listing.location.inspect}"
            end
          end
        else
          puts "No coordinates found for #{address}"
        end
        location.save
        person.location = location
        person.save
        puts "Location for the user is now: #{person.location.inspect}"
        
      end
    end
  end

  def self.down
    say "Running this migration downwards doesn't do anything because we can't know which locations were added by this migration."
  end
end
