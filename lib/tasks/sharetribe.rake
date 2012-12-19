namespace :sharetribe do
  namespace :demo do
    
    # Constant used in demo script location creation
    MAX_LOC_DIFF = 0.04
    
    desc "Reads the demo data from lib/demos and populates the database with that data"
    task :load, [:locale] => :environment do |t, args|
      require 'spreadsheet'
      locale = args[:locale]
      spreadsheet = load_spreadsheet(locale)
      puts "Aborting" and return if spreadsheet.nil?
      
      @community = Community.create(:name => "Demo (#{locale})", :domain => "#{locale}-demo")
      @community.settings = {"locales"=>["#{locale}"]}
      @community.save
      
      
      user_sheet = spreadsheet.worksheet "Users"
      people_array = [nil]
      
      user_sheet.each 1 do |row|
        if row[1].present?
          @community.location = random_location_around(row[9], "community") unless row[9].blank?
          @community.save
          image_path = "lib/demos/images/#{row[8]}" if row[8].present?
          p = Person.create!(
                 :username =>     row[4].downcase,
                 :email =>        row[2],
                 :password =>     "test",
                 :given_name =>   row[4],
                 :family_name =>  row[5],
                 :phone_number => row[6],
                 :description =>  row[7],
                 :location =>     row[9].blank?  ? nil : random_location_around(row[9], "person"),
                 :confirmed_at=>  Time.now,
                 :communities =>  [@community],
                 :image => (image_path && File.exists?(image_path) ? File.new(image_path) : nil)
                 
          )
          people_array << p
        end
      end
      
      listings_sheet = spreadsheet.worksheet "Requests and Offers"
      listings_array = [nil]
      
      listings_sheet.each 1 do |row|
        if row[2].present?
          image_path = "lib/demos/images/#{row[8]}" if row[8].present?
          if image_path && File.exists?(image_path)
            image = ListingImage.new(:image => File.new(image_path))
          end
          l = Listing.create!(
                 :author =>       people_array[row[1]],
                 :title =>        row[2],
                 :description =>  row[3],
                 :listing_type => row[4].downcase,
                 :category =>     row[5].split(" ")[0].downcase,
                 :share_type =>   row[6].blank? ? nil : row[6].downcase,
                 :visibility =>   row[7].downcase,
                 :location =>     row[9].blank?  ? nil : random_location_around(row[9], "origin_loc"),
                 :destination_loc => row[10].blank? ? nil : random_location_around(row[10], "destination_loc"),
                 :origin =>       row[11].blank? ? nil : row[11],
                 :destination  => row[12].blank? ? nil : row[12],
                 :valid_until  => 11.months.from_now,
                 :communities =>  [@community],
                 :listing_images => (image.present? ? [image] : [])     
          )
          listings_array << l
        end
      end
      
      comments_sheet = spreadsheet.worksheet "Comments"
      comments_sheet.each 1 do |row|
        if row[2].present?
          Comment.create(
                      :author => people_array[row[1]],
                      :listing => listings_array[row[0]],
                      :content => row[2]
          )
        end
      end
      
      conversations_sheet = spreadsheet.worksheet "Conversations"
      conversations_array = [nil]
      conversations_sheet.each 1 do |row|
        if row[2].present?
          c = Conversation.create!(
                    :title =>  row[2],
                    :status => row[3].downcase,
                    :listing  =>  listings_array[row[1]]
          )
          conversations_array << c
        end
      end
      

      participations_sheet = spreadsheet.worksheet "Participations"
      participations_array = [nil]
      participations_sheet.each 1 do |row|
        if row[2].present?
          p = Participation.create(
                  :person =>  people_array[row[1]],
                  :conversation => conversations_array[row[2]]
          )
          participations_array << p
        end
      end
      
      messages_sheet = spreadsheet.worksheet "Messages"
      messages_sheet.each 1 do |row|
        if row[2].present?
          Message.create(
                    :sender =>  people_array[row[1]],
                    :conversation => conversations_array[row[2]],
                    :content  => row[3]
          )
          
        end
      end
      
      testimonials_sheet = spreadsheet.worksheet "Testimonials"
      testimonials_sheet.each 1 do |row|
           if row[2].present?
              Testimonial.create(
                        :author =>  people_array[row[1]],
                        :receiver => people_array[row[2]],  
                        :text   =>  row[3],
                        :grade   =>  row[4]/5.0,
                        :participation => participations_array[row[5]]

              )
        end
      end
      
      badges_sheet = spreadsheet.worksheet "Badges"
      badges_sheet.each 1 do |row|
         if row[0].present?
           Badge.create(
                  :name => row[0],
                  :person  => people_array[row[1]]
           )
         
         end
      end
      
      puts "Created 'Demo (#{locale})' community at subdomain: #{locale}-demo"
    end
    
    desc "removes the content created by the demoscript from the DB. It's based on usernames, so don't use if there's a risk of collisions."
    task :clear, [:locale] => :environment do |t, args|
      require 'spreadsheet'
      locale = args[:locale]
      
      
      spreadsheet = load_spreadsheet(locale)
      puts "Aborting" and return if spreadsheet.nil?
      
      c = Community.find_by_domain("#{locale}-demo")
      c.destroy if c
      
      user_sheet = spreadsheet.worksheet "Users"
      user_sheet.each 1 do |row|
        if row[4].present?
          p = Person.find_by_username(row[4])
          p.destroy if p
        end
      end
    end
    
    def load_spreadsheet(locale)
      demo_data_path = "lib/demos/demo_data.#{locale}.xls"
      unless  File.exists?(demo_data_path)
        puts "Could not find #{demo_data_path}"
        return nil
      end
      Spreadsheet.open demo_data_path
    end
  end
  
  
  namespace :community_updates do
    desc "Sends the community updates email to everyone who should receive it now"
    task :deliver => :environment do |t, args|
      PersonMailer.deliver_community_updates
    end
  end
  
  def random_location_around(coordinate_string, location_type)    
    lat = coordinate_string.split(",")[0].to_f + rand*2*MAX_LOC_DIFF - MAX_LOC_DIFF
    lon =  coordinate_string.split(",")[1].to_f + rand*2*MAX_LOC_DIFF - MAX_LOC_DIFF
        
    Location.new(:latitude =>  lat, :longitude =>  lon, :location_type  => location_type, :address => "#{lat},#{lon}", :google_address => "#{lat},#{lon}")
  end
end