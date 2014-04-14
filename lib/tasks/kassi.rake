namespace :kassi do
  desc "Adds people and listings without a community to a community specified in parameter"
  task :add_default_community, [:community_name] => :environment do |t, args|
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
  task :fetch_people_data_from_asi => :environment do |t, args|
    puts "NOTE: the APP_CONFIG.use_asi MUST BE true WHEN RUNNING THIS"
    not_found_count = 0
    `mkdir temp_profile_images`

    Person.all.each do |person|
      #puts "#{person.username} #{person.given_name} #{person.family_name} #{person.email} #{person.phone_number} #{person.description}"
      print "."
      STDOUT.flush

      unless person.username == "Person not found!"
        person.update_attribute(:username, person.username)
        person.update_attribute(:given_name, person.given_name)
        person.update_attribute(:family_name, person.family_name)
        person.update_attribute(:description, person.description)
        person.update_attribute(:phone_number, person.phone_number)

        person.update_attribute(:email, person.email)
        `curl  #{APP_CONFIG.asi_url}/people/#{person.id}/@avatar -o temp_profile_images/#{person.id}`
        f = File.new("temp_profile_images/#{person.id}")
        unless f.size == 16543 # Skip the default avatar returned by ASI
          person.update_attribute(:image, f)
        end

      else
        not_found_count += 1
      end
    end
    puts "\n"
    if not_found_count > 0
      puts "#{not_found_count} PEOPLE WERE NOT FOUND FROM ASI. THEIR DATA IS NOT IMPORTED!"
    end
    `rm -rf temp_profile_images`
  end

  desc "Calculates statistics and stores to DB for all communties where member count is over the minimum level."
  task :calculate_statistics => :environment do |t, args|

    MIN_MEMBER_COUNT_TO_CALCULATE_STATISTICS = 10

    #Calculate statistics for the whole server
    Statistic.create

    # And for all communities bigger than the minimum size
    Community.all.each do |community|
      if community.members.count >= MIN_MEMBER_COUNT_TO_CALCULATE_STATISTICS
        Statistic.create(:community => community)
      end
    end

  end

end
