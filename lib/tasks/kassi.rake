namespace :kassi do
  desc "Adds people and listings without a community to a community specified in parameter"
  task :add_default_community, :community_name, :needs => :environment do |t, args|
    puts "Searching for all Listings and People without a community and adding those to '#{args[:community_name]}' community"
    
    community = Community.find_by_name(args[:community_name])
    
    if community.nil?
      puts "No community found with name '#{args[:community_name]}'"
      return
    end
    
    puts "Looping through the people:"
    Person.all.each do |person|
      if person.communities.empty?
        person.communities.push community
        print "."; STDOUT.flush 
      end
    end
    
    puts "Looping through the listings:"
    Listing.all.each do |listing|
      if listing.communities.empty?
        listing.communities.push community
        print "."; STDOUT.flush
      end
    end
    
    
  end
  
  desc "Fetches people data from ASI and stores it to Kassi DB. This is run before switching from using ASI to run Kassi without ASI"
  task :fetch_people_data_from_asi, :needs => :environment do |t, args|
    not_found_count = 0
    Person.all.each do |person|
      #puts "#{person.username} #{person.given_name} #{person.family_name} #{person.email} #{person.phone_number} #{person.description}"
      print "."
      
      unless person.username == "Person not found!"
        person.update_attribute(:username, person.username)
        person.update_attribute(:given_name, person.given_name)
        person.update_attribute(:family_name, person.family_name)
        person.update_attribute(:description, person.description)
        person.update_attribute(:phone_number, person.phone_number)
        person.update_attribute(:email, person.email)
      else
        not_found_count += 1
      end
    end
    puts "\n"
    if not_found_count > 0
      puts "#{not_found_count} PEOPLE WERE NOT FOUND FROM ASI. THEIR DATA IS NOTE IMPORTED!"
    end
  end
end
