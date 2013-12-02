class Community < ActiveRecord::Base

  require 'compass'
  require 'sass/plugin'

  include EmailHelper

  has_many :community_memberships, :dependent => :destroy 
  has_many :members, :through => :community_memberships, :conditions => ['community_memberships.status = ?', 'accepted'], :source => :person
  has_many :invitations, :dependent => :destroy
  has_many :news_items, :dependent => :destroy
  has_many :polls, :dependent => :destroy
  has_many :event_feed_events, :dependent => :destroy
  has_one :location, :dependent => :destroy
  has_many :community_customizations, :dependent => :destroy
  has_many :community_categories # Don't add here :dependent  => :destroy because community_categories method confuses it. Instead use separate hook (delete_specific_community_categories) to get rid of entries in that table when destroying.
  has_many :categories, :through => :community_categories
  has_many :share_types, :through => :community_categories
  has_many :payments
  has_many :statistics, :dependent => :destroy
  
  has_and_belongs_to_many :listings
  
  has_many :community_payment_gateways, :dependent => :destroy 
  has_many :payment_gateways, :through => :community_payment_gateways
  
  after_create :initialize_settings
  before_destroy :delete_specific_community_categories
  
  monetize :minimum_price_cents, :allow_nil => true
  
  VALID_CATEGORIES = ["company", "university", "association", "neighborhood", "congregation", "town", "apartment_building", "other"]
  
  # Here is a list of subdomain names that we don't want people to reserve for their communities. This should be moved to config.
  RESERVED_SUBDOMAINS = %w{ www wiki mail calendar doc docs admin dashboard translate alpha beta gamma test developer proxy community tribe git partner partners global sharetribe application share dev st aalto ospn kassi video photos fi fr cl gr us usa subdomain abbesses alesia alexandredumas almamarceau anatolefrance antony anvers argentine artsetmetiers asnieresgennevilliers assembleenationale aubervillierspantin avenueemilezola avron balard barbesrochechouart basiliquedesaintdenis bastille belair belleville berault bercy bibliothequefrancoismitterrand billancourt birhakeim blanche bobignypablopicasso bobignypantin boissiere bolivar bonnenouvelle botzaris boucicaut boulognejeanjaures boulognepontdesaintcloud bourse breguetsabin brochant butteschaumont buzenval cadet cambronne campoformio cardinallemoine carrefourpleyel censierdaubenton champselyseesclemenceau chardonlagache charentonecoles charlesdegaulleetoile charlesmichels charonne chateaudeau chateaudevincennes chateaulandon chateaurouge chatelet chatillonmontrouge chausseedantin cheminvert chevaleret cite clunylasorbonne colonelfabien commerce concorde convention corentincariou corentincelton corvisart courcelles couronnes coursaintemilion creteillechat creteilprefecture creteiluniversite crimee croixdechavaux danube daumesnil denfertrochereau dugommier dupleix duroc ecolemilitaire ecoleveterinaire edgarquinet eglisedauteuil eglisedepantin esplanadedeladefense etiennemarcel europe exelmans faidherbechaligny falguiere felixfaure fillesducalvaire fortdaubervilliers franklinroosevelt funiculairegarebasse funiculairegarehaute gabrielperi gaite gallieni gambetta garedausterlitz garedelest garedelyon garedunord garibaldi georgev glaciere goncourt grandsboulevards guymoquet havrecaumartin hoche hoteldeville iena invalides jacquesbonsergent jasmin jaures javelandrecitroen jourdain julesjoffrin jussieu kleber lachapelle lacourneuve8mai1945 ladefense lafourche lamarckcaulaincourt lamottepicquetgrenelle lamuette latourmaubourg laumiere ledrurollin lekremlinbicetre lepeletier lesagnettes lesgobelins leshalles lessablons liberte liege louisblanc louisemichel lourmel louvrerivoli mabillon madeleine mairiedeclichy mairiedemontreuil mairiedesaintouen mairiedeslilas mairiedissy mairiedivry maisonblanche maisonsalfortlesjuilliottes maisonsalfortstade malakoffplateaudevanves malakoffrueetiennedolet malesherbes maraichers marcadetpoissonniers marcelsembat marxdormoy maubertmutualite menilmontant michelangeauteuil michelangemolitor michelbizot mirabeau miromesnil monceau montgallet montparnassebienvenue moutonduvernet nation nationale notredamedelorette notredamedeschamps oberkampf odeon olympiades opera orlyouest orlysud ourcq palaisroyal parmentier passy pasteur pelleport pereire perelachaise pernety philippeauguste picpus pierreetmariecurie pigalle placedeclichy placedesfites placeditalie placemonge plaisance pointedulac poissonniere pontdelevalloisbecon pontdeneuilly pontdesevres pontmarie pontneuf portedauphine portedauteuil portedebagnolet portedechamperret portedecharenton portedechoisy portedeclichy portedeclignancourt portedelachapelle portedelavillette portedemontreuil portedepantin portedesaintcloud portedesaintouen portedeslilas portedevanves portedeversailles portedevincennes porteditalie portedivry portedoree portedorleans portemaillot presaintgervais pyramides pyramides pyrenees quaidelagare quaidelarapee quatreseptembre rambuteau ranelagh raspail reaumursebastopol rennes republique reuillydiderot richardlenoir richelieudrouot riquet robespierre rome ruedelapompe ruedesboulets ruedubac ruesaintmaur saintambroise saintaugustin saintdenisportedeparis saintdenisuniversite saintfargeau saintfrancoisxavier saintgeorges saintgermaindespres saintjacques saintlazare saintmande saintmarcel saintmichel saintpaul saintphilippeduroule saintplacide saintsebastienfroissart saintsulpice segur sentier sevresbabylone sevreslecourbe simplon solferino stalingrad strasbourgsaintdenis sullymorland telegraphe temple ternes tolbiac trinitedestiennedorves trocadero tuileries vaneau varenne vaugirard vavin victorhugo villejuifleolagrange villejuiflouisaragon villejuifpaulvaillantcouturier villiers volontaires voltaire wagram}
  
  validates_length_of :name, :in => 2..50
  validates_length_of :domain, :in => 2..50
  validates_format_of :domain, :with => /^[A-Z0-9_\-\.]*$/i
  validates_uniqueness_of :domain
  validates_length_of :slogan, :in => 2..100, :allow_nil => true
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  validates_format_of :custom_color1, :with => /^[A-F0-9_-]{6}$/i, :allow_nil => true
  validates_format_of :custom_color2, :with => /^[A-F0-9_-]{6}$/i, :allow_nil => true 
  # The settings hash contains some community specific settings:
  # locales: which locales are in use, the first one is the default
    
  serialize :settings, Hash
  
  has_attached_file :logo, 
                    :styles => { 
                      :header => "192x192#",
                      :header_icon => "40x40#",  
                      :original => "600x600>"
                    },
                    :default_url => "/assets/logos/mobile/default.png"
  
  validates_attachment_content_type :logo,
                                    :content_type => ["image/jpeg",
                                                      "image/png", 
                                                      "image/gif", 
                                                      "image/pjpeg", 
                                                      "image/x-png"]
  
  has_attached_file :wide_logo, 
                    :styles => { 
                      :header => "168x40#",  
                      :original => "600x600>"
                    },
                    :default_url => "/assets/logos/full/default.png"
  
  validates_attachment_content_type :wide_logo,
                                    :content_type => ["image/jpeg",
                                                      "image/png", 
                                                      "image/gif", 
                                                      "image/pjpeg", 
                                                      "image/x-png"]
  
  has_attached_file :cover_photo, 
                    :styles => { 
                      :header => "1600x195#",
                      :hd_header => "1920x450#",  
                      :original => "3840x3840>"
                    },
                    :default_url => "/assets/cover_photos/header/default.jpg",
                    :keep_old_files => true # Temporarily to make preprod work aside production
  validates_attachment_content_type :cover_photo,
                                    :content_type => ["image/jpeg",
                                                      "image/png", 
                                                      "image/gif", 
                                                      "image/pjpeg", 
                                                      "image/x-png"]
  
  attr_accessor :terms
  
  def address
    location ? location.address : nil
  end
  
  def default_locale
    if settings && !settings["locales"].blank?
      return settings["locales"].first
    else
      return APP_CONFIG.default_locale
    end
  end
  
  def locales
   if settings && !settings["locales"].blank?
      return settings["locales"]
    else
      # if locales not set, return the short locales from the default list
      return Kassi::Application.config.AVAILABLE_LOCALES.collect{|loc| loc[1]}
    end
  end
  
  # Return the people who are admins of this community
  def admins
    members.joins(:community_memberships).where("community_memberships.admin = '1'").group("people.id")
  end
  
  # Returns the emails of admins in an array
  def admin_emails
    admins.collect { |p| p.confirmed_notification_email_addresses } .flatten
  end
  
  def allows_user_to_send_invitations?(user)
    (users_can_invite_new_users && user.member_of?(self)) || user.has_admin_rights_in?(self)
  end
  
  def has_customizations?
    if APP_CONFIG.preproduction
      preproduction_stylesheet_url.present?
    else
      stylesheet_url.present?
    end
  end
  
  def custom_stylesheet_url
    if APP_CONFIG.preproduction
      self.preproduction_stylesheet_url        
    else
      self.stylesheet_url
    end
  end
  
  def self.with_customizations
    where("custom_color1 IS NOT NULL OR cover_photo_file_name IS NOT NULL")
  end
  
  # If community name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def name_with_separator(locale)
    (name.include?(" ") && locale.to_s.eql?("fi")) ? "#{name} " : name
  end
  
  # If community full name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def full_name_with_separator(locale)
    (full_name.include?(" ") && locale.to_s.eql?("fi")) ? "#{full_name} " : full_name
  end
  
  def active_poll
    polls.where(:active => true).first
  end
  
  def set_email_confirmation_on_and_send_mail_to_existing_users
    # If email confirmation is already active, do nothing
    return if self.email_confirmation == true
    
    self.email_confirmation = true
    save
    
    original_locale = I18n.locale
    
    #Store host to global variable to be able to use this from console
    $host = full_domain
    
    members.all.each do |member|
      member.confirmed_at = nil
      member.save
      I18n.locale = member.locale
      member.send_confirmation_instructions(full_domain, self)
      
    end
    I18n.locale = original_locale
  end
  
  def email_all_members(subject, mail_content, default_locale="en", verbose=false)
    puts "Sending mail to all #{members.count} members in community: #{self.name}" if verbose
    PersonMailer.deliver_open_content_messages(members.all, subject, mail_content, default_locale, verbose)
  end

  # Makes the creator of the community a member and an admin
  def admin_attributes=(attributes)
    community_memberships.build(attributes).update_attribute("admin", true)
  end
  
  def self.domain_available?(domain)
    ! (RESERVED_SUBDOMAINS.include?(domain) || find_by_domain(domain).present?)
  end
  
  def self.find_by_email_ending(email)
    Community.all.each do |community|
      return community if community.allowed_emails && community.email_allowed?(email)
    end
    return nil
  end
  
  def new_members_during_last(time)
    community_memberships.where(:created_at => time.ago..Time.now).collect(&:person)
  end

  # Returns the full domain with default protocol in front
  def full_url
    full_domain(:with_protocol => true)
  end
  
  #returns full domain without protocol
  def full_domain(options= {})
    # assume that if  port is used in domain config, it should 
    # be added to the end of the full domain for links to work
    # This concerns usually mostly testing and development
    port_string = APP_CONFIG.domain[/\:\d+$/]
    
    if self.domain =~ /\./ # custom domain
      dom = "#{self.domain}#{port_string}"
    else # just a subdomain specified
      dom = "#{self.domain}.#{APP_CONFIG.domain}"
    end
    
    if options[:with_protocol]
      dom = "#{(APP_CONFIG.always_use_ssl ? "https://" : "http://")}#{dom}"
    end
    
    return dom
    
  end
  
  # returns the community specific service name if such is in use
  # otherwise returns the global default
  def service_name
    if settings && settings["service_name"].present?
      settings["service_name"]
    else
      APP_CONFIG.global_service_name || "Sharetribe"
    end
  end

  def has_new_listings_since?(time)
    return listings.where("created_at > ?", time).present?
  end

  def self.find_by_allowed_email(email)
    email_ending = "@#{email.split('@')[1]}"
    where("allowed_emails LIKE '%#{email_ending}%'")
  end
  
  # Find community by domain, which can be full domain or just subdomain
  def self.find_by_domain(domain_string)
    if domain_string =~ /\:/ #string includes port which should be removed
      domain_string = domain_string.split(":").first
    end

    # search for exact match or then match by first part of domain string.
    # first priority is the domain, then domain_alias
    return Community.where(["domain = ?", domain_string]).first || 
           Community.where(["domain = ?", domain_string.split(".").first]).first ||
           Community.where(["domain_alias = ?", domain_string]).first ||
           Community.where(["domain_alias = ?", domain_string.split(".").first]).first
  end
  
  # Check if communities with this category are email restricted
  def self.email_restricted?(community_category)
    ["company", "university"].include?(community_category)
  end
  
  # Returns all the people who are admins in at least one tribe.
  def self.all_admins
    Person.joins(:community_memberships).where("community_memberships.admin = '1'").group("people.id")
  end
  
  # Generates the customization stylesheet scss files to app/assets
  # This should be run before assets:precompile in order to precompile stylesheets for each community that has customizations
  def self.generate_customization_stylesheets
    Community.with_customizations.each do |community|
      puts "Generating custom CSS for #{community.name}"
      STDOUT.flush # trying to get the prints out sooner while deploying to heroku
      community.generate_customization_stylesheet
    end
  end
  
  def generate_customization_stylesheet
    if custom_color1 || custom_color2 || cover_photo.present?
      community_filename = domain.gsub(".", "_")
      stylesheet_filename = "custom-style-#{community_filename}"
      new_filename_with_time_stamp = "#{stylesheet_filename}-#{Time.now.strftime("%Y%m%d%H%M%S")}"

      
      # Copy original SCSS and do customizations by search & replace
      
      # Create new stylesheet for community
      FileUtils.cp("app/assets/stylesheets/application.scss", "app/assets/stylesheets/#{stylesheet_filename}.scss" )
      
      # Use default-colors as a starting point for customizations
      FileUtils.cp("app/assets/stylesheets/default-colors.scss", "app/assets/stylesheets/customizations.scss" )

      if custom_color1.present? 
        replace_in_file("app/assets/stylesheets/customizations.scss",
                        /\$link:\s*#\w{6};/,
                        "$link: ##{custom_color1};",
                        true)
      end
      color2 = custom_color2 || custom_color1
      if color2.present? 
        replace_in_file("app/assets/stylesheets/customizations.scss",
                        /\$link2:\s*#\w{6};/,
                        "$link2: ##{color2};",
                        true)
      end
      if cover_photo.present?
        replace_in_file("app/assets/stylesheets/customizations.scss",
                        /\$cover-photo-url:\s*\"[^\"]+\";/,
                        "$cover-photo-url: \"#{cover_photo.url(:hd_header)}\";",
                        true)
      end
      url = stylesheet_filename
      unless false #Rails.env.development? # Dev mode uses on-the-fly SCSS compiling
        
        # Generate CSS from SCSS
        css_file = "public/assets/#{new_filename_with_time_stamp}.css"
        `mkdir public/assets` unless File.exists?("public/assets")

        sprockets = Sprockets::Environment.new(Rails.root).tap do |env|
          env.append_path File.join(env.root, 'app/assets/stylesheets')

          env.context_class.instance_eval do
            # Include these helpers to allow SASS files to use image-url etc. helpers
            include Sprockets::Helpers::RailsHelper
            include Sprockets::Helpers::IsolatedHelper

            def sass_config
              ActiveSupport::OrderedOptions.new.tap do |s|
                compass = Compass::Frameworks['compass']

                s.load_paths = [
                  # File.join($root, 'app/assets/stylesheets'),
                  compass.stylesheets_directory,
                  compass.templates_directory
                ]

                # Here we can add SASS configurations, such as:
                # s.style = :expanded
              end
            end
          end
        end

        asset = sprockets["#{stylesheet_filename}.scss"]
        asset.write_to(css_file)

        # Empty the file
        File.open("app/assets/stylesheets/customizations.scss", 'w') {}
        
        url = new_filename_with_time_stamp
        
        # If using S3 as storage (e.g. in Heroku) need to move the generated files to S3
        if ApplicationHelper.use_s3?
          
          AWS.config :access_key_id =>  APP_CONFIG.aws_access_key_id,  :secret_access_key => APP_CONFIG.aws_secret_access_key
          s3 = AWS::S3.new
          b = s3.buckets.create(APP_CONFIG.s3_bucket_name)
          basename = File.basename("#{Rails.root}/#{css_file}")
          o = b.objects["assets/custom/#{basename}"]
          o.write(:file => "#{Rails.root}/#{css_file}", :cache_control => "public, max-age=30000000", :content_type => "text/css")
          o.acl = :public_read
          url = o.public_url.to_s
          
        end
      end
      
      # If we are at preproduction, only update the preproduction_stylesheet_url in order not
      # to disturb what's happening at production.
      # Normally update the stylesheet_url
      
      if APP_CONFIG.preproduction
        update_attribute(:preproduction_stylesheet_url, url)        
      else
        update_attribute(:stylesheet_url, url)
      end
    end
  end
  
  def replace_in_file(file_name, search, replace, only_once=false)
    text = File.read(file_name)
    File.open(file_name, "w") do |f|
      if only_once
        f.write(text.sub(search, replace))
      else
        f.write(text.gsub(search, replace))
      end
    end
  end
  
  # approves a membership pending email if one is found
  # if email is given, only approves if email is allowed
  # returns true if membership was now approved
  # false if it wasn't allowed or if already a member
  def approve_pending_membership(person, email_address=nil)
    membership = community_memberships.where(:person_id => person.id, :status => "pending_email_confirmation").first
    if membership && (email_address.nil? || email_allowed?(email_address)) 
      membership.update_attribute(:status, "accepted")
      return true
    end
    return false
  end
  
  def full_name
    settings["service_name"] ? settings["service_name"] : "Sharetribe #{name}"
  end
  
  def uses_rdf_profile_import?
    settings["use_rdf_profile_import"] == true    
  end
  
  # categories_tree
  # Returns a hash that represents the categorization tree that is in use at this community
  # Some assumptions are made here:
  # - Listing types and share_types are only linked to top level categories in DB
  # If wanting to do differently, this code needs to be changed and probably the UI code too
  # Example of a returned tree:
  #   "offer" => {
  #     "item" => {
  #       "subcategory" => ["tools", "sports", "music", "books", "games"],
  #       "share_type" => ["lend", "sell", "rent_out", "trade", "give_away"]
  #     },
  #     "favor" => {
  #       "subcategory" => ["furniture_assemble", "walking_dogs"]
  #     }, 
  #     "rideshare" => {},
  #     "housing" => {
  #       "share_type" => ["rent_out", "sell", "share_for_free"]
  #     }
  #   },
  #   "request" => {
  #     "rideshare" => {}
  #   }
  # }
  def categories_tree
    tree = {}
    
    # store few variables here so that they are fetched only once during the loops
    this_tribe_community_categories = community_categories
    this_tribe_categories = categories
    this_tribe_share_types = share_types
    
    listing_types.each do |listing_type| # Listing types are the root level of the tree
      categories_for_listing_type = {}
      
      # pick the categories that are linked for this listing type in this community
      # "top_level_linked_community_category" means that we assume here that those categories that are linked
      # to listing types, are top level categories (not sub categories)
      this_tribe_community_categories.select{|cc| cc.share_type_id == listing_type.id}.each do |top_level_linked_community_category|
        
        category_hash = {} # empty by default if no subcategories or share_types

        # Check for existing subcategories for this category
        this_tribe_categories.select{|cat| cat.parent_id == top_level_linked_community_category.category_id}.each do |subcat|
          category_hash["subcategory"] ||= []
          category_hash["subcategory"] << subcat.name
        end
        
        # Check for existing linked share_types for this category
        this_tribe_share_types.select{|st|  
                this_tribe_community_categories.select{|comcat| 
                  comcat.category_id == top_level_linked_community_category.category_id && 
                  st.id == comcat.share_type_id
                }.present? &&
                st.parent_id == top_level_linked_community_category.share_type_id}.each do |sub_share_type|
          category_hash["share_type"] ||= []
          category_hash["share_type"] << sub_share_type.name
        end
        
        # Insert this top level category to hash and make it's value contain the sub categories and share types
        categories_for_listing_type[top_level_linked_community_category.category.name] = category_hash
      end
      
      tree[listing_type.name] = categories_for_listing_type
    end
    return tree
  end
  
  
  # available_categorization_values
  # Returns a hash of lists of values for different categorization aspects in use in this community
  # Used to simplify UI building
  # Example hash:
  # {
  #   "listing_type" => ["offer", "request"],
  #   "category" => ["item", "favor", "rideshare", "housing"],
  #   "subcategory" => ["tools", "sports", "music", "books", "games", "furniture_assemble", "walking_dogs"],
  #   "share_type" => ["lend", "sell", "rent_out", "give_away", "share_for_free", "borrow", "buy", "rent", "trade", "receive", "accept_for_free"]
  # }
  def available_categorization_values
    values = {}
    values["listing_type"] = listing_types.collect(&:name)
    values["category"] = main_categories.collect(&:name)
    values["subcategory"] = subcategories.collect(&:name)
    values["share_type"] = share_types.collect(&:name).reject { |st| values["listing_type"].include?(st) }
    return values
  end
  
  # same as available_categorization_values but returns the models instead of just values
  def available_categorizations
    values = {}
    values["listing_type"] = listing_types
    values["category"] = main_categories
    values["subcategory"] = subcategories
    values["share_type"] = share_types.reject { |st| listing_types.include?(st) }
    return values
  end
  

  # returns all categories
  def categories
    unique_categorizations(:category)
  end
  
  def main_categories
    categories.select{|c| c.parent_id.nil?}
  end
  
  def subcategories
    categories.select{|c| ! c.parent_id.nil?}
  end
  
  # Finds all top level share_types (=listing_types) used in this community
  def listing_types
    share_types.select{|s| s.parent_id.nil?}
  end
  
  # finds community specific share_types or default values if no customizations found
  def share_types
    unique_categorizations(:share_type)
  end
  
  def community_category(category, share_type)
    CommunityCategory.where("category_id = ? AND share_type_id = ? AND (community_id IS NULL OR community_id = ?)", category.id.to_s, share_type.id.to_s, id.to_s).order("category_id DESC").first
  end

  # is it possible to pay for this listing via the payment system
  def payment_possible_for?(listing)
    cc = community_category(listing.category.top_level_parent, listing.share_type)
    # as currently all messages are shown in all communities, there might be case where the
    # message would have payment possible in it's original community, but in this community the cc
    # is not found with the above search, so then payment is not possible here. (cc must be present)
    payments_in_use? && cc.present? && (cc.price || cc.payment)
  end
  
  def payments_in_use?
    payment_gateways.present?
  end
  
  # Does this community require that people have registered payout method before accepting requests
  def requires_payout_registration?
    payment_gateways.present? && payment_gateways.first.requires_payout_registration_before_accept?
  end


  def community_categories
    custom = Rails.cache.fetch("/custom_categories/#{self.id}-#{self.updated_at}") {
      # order the custom categorizations based on the sort priority (or ids of the CommunityCategory)
      CommunityCategory.order("sort_priority ASC","id ASC").find_all_by_community_id(id, :include => [:category, :share_type])
    }
    if custom.present?
      # use custom values
      return custom
    else
      # Use defaults
      return Rails.cache.fetch("/default_categories") {
        CommunityCategory.find_all_by_community_id(nil, :include => [:category, :share_type])
      }
    end
  end
  
  def default_currency
    if available_currencies
      available_currencies.split(",").first
    else
      MoneyRails.default_currency
    end
  end
  
  def facebook_login_method(host=nil)
    if facebook_connect_id && (!host || full_domain.match(host))
      return "facebook_app_#{facebook_connect_id}".to_sym
    else
      return :facebook
    end
  end

  def self.all_with_custom_fb_login
    begin
      where("facebook_connect_id IS NOT NULL")
    rescue Mysql2::Error
      # in some environments (e.g. Travis CI) the tables are not yet loaded when this is called
      # so return empty array, as it shouldn't matter in those cases
      return []
    end
  end
  
  def braintree_in_use?
    payment_gateways.include?(PaymentGateway.find_by_type("Braintree"))
  end
  
  # Returns the total service fee for a certain listing
  # in the current community (including gateway fee, platform
  # fee and marketplace fee)
  def service_fee_for(listing)
    (listing.price * (commission_from_seller.to_f/100)).to_f.ceil
  end
  
  # Price that the seller gets after the service fee is deducted
  def price_seller_gets_for(listing)
    listing.price - Money.new(service_fee_for(listing)*100, listing.currency)
  end
  
  private
  
  # Returns an array of unique categories or share_types used in this community.
  def unique_categorizations(categorization_type)
    unless [:category, :share_type].include?(categorization_type)
      throw "unique_categorizations called with wrong type. Only :category and :share_type allowed" 
    end
    return community_categories.collect(&categorization_type).compact.uniq
  end

  def initialize_settings
    update_attribute(:settings,{"locales"=>[APP_CONFIG.default_locale]}) if self.settings.blank?
  end
  
  # This method deletes the specific community_category entries (but not the default ones)
  def delete_specific_community_categories
    CommunityCategory.find_all_by_community_id(id).each do |c|
      c.destroy
    end
  end

end
