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
end
