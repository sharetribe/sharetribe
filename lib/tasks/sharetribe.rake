namespace :sharetribe do

  def run_rake(task)
    print "rake #{task}: "
    $stdout.flush
    Rake::Task[task].invoke
    print "Done.\n"
    $stdout.flush
  end

  task :"setup_dev" do
    run_rake "db:migrate"
    run_rake "test:prepare"
    run_rake "ts:rebuild"

    puts ""
    puts "You may also need to:"
    puts "- rake jobs:work"
    puts ""

    puts "Done."
  end

  namespace :demo do

    # Constant used in demo script location creation
    MAX_LOC_DIFF = 0.04

    desc "Reads the demo data from lib/demos and populates the database with that data"
    task :load, [:locale] => :environment do |t, args|
      require 'spreadsheet'
      locale = args[:locale]
      spreadsheet = load_spreadsheet(locale)
      puts "Aborting" and return if spreadsheet.nil?

      community = create_community(spreadsheet, locale)

      load_demo_content(community, spreadsheet)
    end

    desc "removes the content created by the demoscript from the DB. It's based on usernames, so don't use if there's a risk of collisions."
    task :clear, [:locale] => :environment do |t, args|
      require 'spreadsheet'
      locale = args[:locale]

      spreadsheet = load_spreadsheet(locale)
      puts "Aborting" and return if spreadsheet.nil?

      community_sheet = spreadsheet.worksheet "Community"
      community_domain = community_sheet.row(1)[1]

      c = Community.find_by_domain(community_domain)
      c.destroy if c

      user_sheet = spreadsheet.worksheet "Users"
      user_sheet.each 1 do |row|
        if row[4].present?
          p = Person.find_by_username(row[4])
          p.destroy if p
        end
      end
    end

    desc "Empties the demo community and resets the default user's etc."
    task :reset, [:locale] => :environment do |t, args|
      require 'spreadsheet'
      locale = args[:locale]

      spreadsheet = load_spreadsheet(locale)
      puts "Aborting" and return if spreadsheet.nil?

      community_sheet = spreadsheet.worksheet "Community"
      community_domain = community_sheet.row(1)[1]

      c = Community.find_by_domain(community_domain)

      c.community_memberships.destroy_all

      c.listings.destroy_all

      user_sheet = spreadsheet.worksheet "Users"
      user_sheet.each 1 do |row|
        if row[4].present?
          p = Person.find_by_username(row[4])
          p.destroy if p
        end
      end

      c.destroy
      c = create_community(spreadsheet, locale)

      load_demo_content(c, spreadsheet)
      puts "Reloaded #{locale} demo contet to community at subdomain: #{community_domain}"
    end

    def load_spreadsheet(locale)
      demo_data_path = "lib/demos/demo_data.#{locale}.xls"
      unless  File.exists?(demo_data_path)
        puts "Could not find #{demo_data_path}"
        return nil
      end
      Spreadsheet.open demo_data_path
    end

    def load_demo_content(community, spreadsheet)

      user_sheet = spreadsheet.worksheet "Users"
      people_array = [nil]
      demo_auth_token_created = false

      user_sheet.each 1 do |row|
        if row[1].present?
          community.location = random_location_around(row[9], "community") unless row[9].blank?
          community.save
          image_path = "lib/demos/images/#{row[8]}" if row[8].present?
          p = Person.create!(
                 :username =>     row[4].downcase,
                 :password =>     "test",
                 :given_name =>   row[4],
                 :family_name =>  row[5],
                 :phone_number => row[6],
                 :description =>  row[7],
                 :location =>     row[9].blank?  ? nil : random_location_around(row[9], "person"),
                 :communities =>  [community]
          )

          e = Email.create!(:person_id => p.id, :address => row[2], :confirmed_at=>  Time.now, :send_notifications => true)

          CommunityMembership.find_by_person_id_and_community_id(p.id, community.id).update_attribute(:admin, 1) if row[9].present?
          p.update_attribute(:image, File.new(image_path)) if image_path && File.exists?(image_path)
          people_array << p
          demo_auth_token_created = create_demo_auth_token_for(p, community.domain) unless demo_auth_token_created
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

          category = Category.find_by_name(row[5].split(" ")[0].downcase)
          share_type = ShareType.find_by_name(row[6].blank? ? row[4].downcase : row[6].downcase)
          l = Listing.create!(
                 :author =>       people_array[row[1]],
                 :title =>        row[2],
                 :description =>  row[3],
                 :category =>     category,
                 :share_type =>   share_type,
                 :visibility =>   row[7].downcase,
                 :privacy =>      "public",
                 :location =>     row[9].blank?  ? nil : random_location_around(row[9], "origin_loc"),
                 :destination_loc => row[10].blank? ? nil : random_location_around(row[10], "destination_loc"),
                 :origin =>       row[11].blank? ? nil : row[11],
                 :destination  => row[12].blank? ? nil : row[12],
                 :price_cents => (row[14].present? ? row[14]*100 : nil),
                 :currency => "EUR",
                 :valid_until  => 5.months.from_now,
                 :communities =>  [community],
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
              Testimonial.create!(
                        :author =>  people_array[row[1]],
                        :receiver => people_array[row[2]],
                        :text   =>  row[3],
                        :grade   =>  row[4],
                        :participation => participations_array[row[5]]

              )
        end
      end
    end

    def create_demo_auth_token_for(p, token)
      AuthToken.create(:person => p, :expires_at => 1.year.from_now, :token => token)
    end

    def create_community(spreadsheet, locale)
      community_sheet = spreadsheet.worksheet "Community"
      community_name = community_sheet.row(1)[0]
      community_domain = community_sheet.row(1)[1]
      community_slogan = community_sheet.row(1)[3] if community_sheet.row(1)[3].present?
      community_description = community_sheet.row(1)[4] if community_sheet.row(1)[4].present?

      community = Community.create(:name => community_name, :domain => community_domain, :slogan => community_slogan, :description => community_description  )
      community.settings = {"locales"=>["#{locale}"]}
      community.badges_in_use = community_sheet.row(1)[2]
      community.save

      puts "Created '#{community_name}' community at subdomain: #{community_domain}"

      return community
    end
  end

  namespace :community_updates do
    desc "Sends the community updates email to everyone who should receive it now"
    task :deliver => :environment do |t, args|
      CommunityMailer.deliver_community_updates
    end
  end

  def random_location_around(coordinate_string, location_type)
    lat = coordinate_string.split(",")[0].to_f + rand*2*MAX_LOC_DIFF - MAX_LOC_DIFF
    lon =  coordinate_string.split(",")[1].to_f + rand*2*MAX_LOC_DIFF - MAX_LOC_DIFF
    address = coordinate_string.split(",")[2] || "#{lat},#{lon}"

    Location.new(:latitude =>  lat, :longitude =>  lon, :location_type  => location_type, :address => address, :google_address => "#{lat},#{lon}")
  end

  desc "Generates customized CSS stylesheets in the background"
  task :generate_customization_stylesheets => :environment do
    # If preboot in use, give 2 minutes time to load new code
    delayed_opts = {priority: 8, :run_at => 2.minutes.from_now }
    CommunityStylesheetCompiler.compile_all(delayed_opts)
  end

  desc "Generates customized CSS stylesheets immediately"
  task :generate_customization_stylesheets_immediately => :environment do
    CommunityStylesheetCompiler.compile_all_immediately()
  end

  desc "Updates the Category and ShareType translations in DB based on the normal translation files"
  task :update_categorization_translations => :environment do
    # Updating translations this way is no more used
    #CategoriesHelper.update_translations
  end

  desc "Cleans the auth_tokens table in the DB by deleting expired ones"
  task :delete_expired_auth_tokens => :environment do
    AuthToken.delete_expired
  end

  desc "Retries set express checkouts"
  task :retry_and_clean_paypal_tokens => :environment do
    Delayed::Job.enqueue(PaypalService::Jobs::RetryAndCleanTokens.new(1.hour.ago))
  end
end
