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

  has_many :categories, :order => "sort_priority"
  has_many :top_level_categories, :class_name => "Category", :conditions => ["parent_id IS NULL"], :order => "sort_priority"
  has_many :subcategories, :class_name => "Category", :conditions => ["parent_id IS NOT NULL"], :order => "sort_priority"

  has_many :conversations
  has_many :payments
  has_many :statistics, :dependent => :destroy
  has_many :transaction_types, :dependent => :destroy, :order => "sort_priority"

  has_and_belongs_to_many :listings

  has_one :payment_gateway, :dependent => :destroy

  has_many :custom_fields, :dependent => :destroy
  has_many :custom_dropdown_fields, :class_name => "CustomField", :conditions => ["type = 'DropdownField'"], :dependent => :destroy
  has_many :custom_numeric_fields, :class_name => "NumericField", :conditions => ["type = 'NumericField'"], :dependent => :destroy

  after_create :initialize_settings

  monetize :minimum_price_cents, :allow_nil => true

  VALID_CATEGORIES = ["company", "university", "association", "neighborhood", "congregation", "town", "apartment_building", "other"]

  # Here is a list of subdomain names that we don't want people to reserve for their communities. This should be moved to config.
  RESERVED_SUBDOMAINS = %w{ www wiki mail calendar doc docs admin dashboard translate alpha beta gamma test developer proxy community tribe git partner partners global sharetribe application share dev st aalto ospn kassi video photos fi fr cl gr us usa subdomain abbesses alesia alexandredumas almamarceau anatolefrance antony anvers argentine artsetmetiers asnieresgennevilliers assembleenationale aubervillierspantin avenueemilezola avron balard barbesrochechouart basiliquedesaintdenis bastille belair belleville berault bercy bibliothequefrancoismitterrand billancourt birhakeim blanche bobignypablopicasso bobignypantin boissiere bolivar bonnenouvelle botzaris boucicaut boulognejeanjaures boulognepontdesaintcloud bourse breguetsabin brochant butteschaumont buzenval cadet cambronne campoformio cardinallemoine carrefourpleyel censierdaubenton champselyseesclemenceau chardonlagache charentonecoles charlesdegaulleetoile charlesmichels charonne chateaudeau chateaudevincennes chateaulandon chateaurouge chatelet chatillonmontrouge chausseedantin cheminvert chevaleret cite clunylasorbonne colonelfabien commerce concorde convention corentincariou corentincelton corvisart courcelles couronnes coursaintemilion creteillechat creteilprefecture creteiluniversite crimee croixdechavaux danube daumesnil denfertrochereau dugommier dupleix duroc ecolemilitaire ecoleveterinaire edgarquinet eglisedauteuil eglisedepantin esplanadedeladefense etiennemarcel europe exelmans faidherbechaligny falguiere felixfaure fillesducalvaire fortdaubervilliers franklinroosevelt funiculairegarebasse funiculairegarehaute gabrielperi gaite gallieni gambetta garedausterlitz garedelest garedelyon garedunord garibaldi georgev glaciere goncourt grandsboulevards guymoquet havrecaumartin hoche hoteldeville iena invalides jacquesbonsergent jasmin jaures javelandrecitroen jourdain julesjoffrin jussieu kleber lachapelle lacourneuve8mai1945 ladefense lafourche lamarckcaulaincourt lamottepicquetgrenelle lamuette latourmaubourg laumiere ledrurollin lekremlinbicetre lepeletier lesagnettes lesgobelins leshalles lessablons liberte liege louisblanc louisemichel lourmel louvrerivoli mabillon madeleine mairiedeclichy mairiedemontreuil mairiedesaintouen mairiedeslilas mairiedissy mairiedivry maisonblanche maisonsalfortlesjuilliottes maisonsalfortstade malakoffplateaudevanves malakoffrueetiennedolet malesherbes maraichers marcadetpoissonniers marcelsembat marxdormoy maubertmutualite menilmontant michelangeauteuil michelangemolitor michelbizot mirabeau miromesnil monceau montgallet montparnassebienvenue moutonduvernet nation nationale notredamedelorette notredamedeschamps oberkampf odeon olympiades opera orlyouest orlysud ourcq palaisroyal parmentier passy pasteur pelleport pereire perelachaise pernety philippeauguste picpus pierreetmariecurie pigalle placedeclichy placedesfites placeditalie placemonge plaisance pointedulac poissonniere pontdelevalloisbecon pontdeneuilly pontdesevres pontmarie pontneuf portedauphine portedauteuil portedebagnolet portedechamperret portedecharenton portedechoisy portedeclichy portedeclignancourt portedelachapelle portedelavillette portedemontreuil portedepantin portedesaintcloud portedesaintouen portedeslilas portedevanves portedeversailles portedevincennes porteditalie portedivry portedoree portedorleans portemaillot presaintgervais pyramides pyramides pyrenees quaidelagare quaidelarapee quatreseptembre rambuteau ranelagh raspail reaumursebastopol rennes republique reuillydiderot richardlenoir richelieudrouot riquet robespierre rome ruedelapompe ruedesboulets ruedubac ruesaintmaur saintambroise saintaugustin saintdenisportedeparis saintdenisuniversite saintfargeau saintfrancoisxavier saintgeorges saintgermaindespres saintjacques saintlazare saintmande saintmarcel saintmichel saintpaul saintphilippeduroule saintplacide saintsebastienfroissart saintsulpice segur sentier sevresbabylone sevreslecourbe simplon solferino stalingrad strasbourgsaintdenis sullymorland telegraphe temple ternes tolbiac trinitedestiennedorves trocadero tuileries vaneau varenne vaugirard vavin victorhugo villejuifleolagrange villejuiflouisaragon villejuifpaulvaillantcouturier villiers volontaires voltaire wagram}

  # Plan levels
  FREE_PLAN = 0
  STARTER_PLAN = 1
  BASIC_PLAN = 2
  GROWTH_PLAN = 3
  SCALE_PLAN = 4

  validates_length_of :name, :in => 2..50
  validates_length_of :domain, :in => 2..50
  validates_format_of :domain, :with => /^[A-Z0-9_\-\.]*$/i
  validates_uniqueness_of :domain
  validates_length_of :slogan, :in => 2..100, :allow_nil => true
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  validates_format_of :custom_color1, :with => /^[A-F0-9_-]{6}$/i, :allow_nil => true
  validates_format_of :custom_color2, :with => /^[A-F0-9_-]{6}$/i, :allow_nil => true

  VALID_BROWSE_TYPES = %{grid map list}
  validates_inclusion_of :default_browse_view, :in => VALID_BROWSE_TYPES

  VALID_NAME_DISPLAY_TYPES = %{first_name_only first_name_with_initial}
  validates_inclusion_of :default_browse_view, :in => VALID_BROWSE_TYPES, :allow_nil => true, :allow_blank => true

  # The settings hash contains some community specific settings:
  # locales: which locales are in use, the first one is the default

  serialize :settings, Hash

  has_attached_file :logo,
                    :styles => {
                      :header => "192x192#",
                      :header_icon => "40x40#",
                      :apple_touch => "152x152#",
                      :original => "600x600>"
                    },
                    :convert_options => {
                      # iOS makes logo background black if there's an alpha channel
                      # And the options has to be in correct order! First background, then flatten. Otherwise it will
                      # not work.
                      :apple_touch => "-background white -flatten"
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

  has_attached_file :small_cover_photo,
                    :styles => {
                      :header => "1600x195#",
                      :hd_header => "1920x96#",
                      :original => "3840x3840>"
                    },
                    :default_url => "/assets/cover_photos/header/default.jpg",
                    :keep_old_files => true # Temporarily to make preprod work aside production

  validates_attachment_content_type :small_cover_photo,
                                    :content_type => ["image/jpeg",
                                                      "image/png",
                                                      "image/gif",
                                                      "image/pjpeg",
                                                      "image/x-png"]

  has_attached_file :favicon,
                    :styles => {
                      :favicon => "32x32#"
                    },
                    :default_style => :favicon,
                    :convert_options => {
                      :favicon => "-depth 32",
                      :favicon => "-strip"
                    },
                    :default_url => "/assets/favicon.ico"

  validates_attachment_content_type :favicon,
                                    :content_type => ["image/jpeg",
                                                      "image/png",
                                                      "image/gif",
                                                      "image/x-icon",
                                                      "image/vnd.microsoft.icon"]

  validates_format_of :twitter_handle, with: /^[A-Za-z0-9_]{1,15}$/, allow_nil: true

  attr_accessor :terms

  def name(locale=nil)
    if locale
      cc = community_customizations.find_by_locale(locale)
      (cc && cc.name) ? cc.name : super()
    else
      super()
    end
  end

  def full_name(locale)
    settings["service_name"] ? settings["service_name"] : "Sharetribe #{name(locale)}"
  end

  # If community name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def name_with_separator(locale)
    (name(locale).include?(" ") && locale.to_s.eql?("fi")) ? "#{name(locale)} " : name(locale)
  end

  # If community full name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def full_name_with_separator(locale)
    (full_name(locale).include?(" ") && locale.to_s.eql?("fi")) ? "#{full_name(locale)} " : full_name(locale)
  end

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
    custom_color1 || custom_color2 || cover_photo.present? || small_cover_photo.present?
  end

  def has_custom_stylesheet?
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
    where("custom_color1 IS NOT NULL OR cover_photo_file_name IS NOT NULL OR small_cover_photo_file_name IS NOT NULL")
  end

  def active_poll
    polls.where(:active => true).first
  end

  def email_all_members(subject, mail_content, default_locale="en", verbose=false)
    puts "Sending mail to all #{members.count} members in community: #{self.name(default_locale)}" if verbose
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

  def self.stylesheet_needs_recompile!
    Community.with_customizations.update_all(:stylesheet_needs_recompile => true)
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

  def uses_rdf_profile_import?
    settings["use_rdf_profile_import"] == true
  end

  # Returns an array that contains the hierarchy of categories and transaction types
  #
  # An xample of a returned tree:
  #
  # [
  #   {
  #     "label" => "item",
  #     "id" => id,
  #     "subcategories" => [
  #       {
  #         "label" => "tools",
  #         "id" => id,
  #         "transaction_types" => [
  #           {
  #             "label" => "sell",
  #             "id" => id
  #           }
  #         ]
  #       }
  #     ]
  #   },
  #   {
  #     "label" => "services",
  #     "id" => "id"
  #   }
  # ]
  def category_tree(locale)
    top_level_categories.inject([]) do |category_array, category|
      category_array << hash_for_category(category, locale)
    end
  end

  # Returns a hash for a single category
  def hash_for_category(category, locale)
    category_hash = {"id" => category.id, "label" => category.display_name(locale)}
    if category.children.empty?
      category_hash["transaction_types"] = category.transaction_types.inject([]) do |transaction_type_array, transaction_type|
        transaction_type_array << {"id" => transaction_type.id, "label" => transaction_type.display_name(locale)}
        transaction_type_array
      end
    else
      category_hash["subcategories"] = category.children.inject([]) do |subcategory_array, subcategory|
        subcategory_array << hash_for_category(subcategory, locale)
        subcategory_array
      end
    end
    category_hash
  end

  # available_categorization_values
  # Returns a hash of lists of values for different categorization aspects in use in this community
  # Used to simplify UI building
  # Example hash:
  # {
  #   "listing_type" => ["offer", "request"],
  #   "category" => ["item", "favor", "housing"],
  #   "subcategory" => ["tools", "sports", "music", "books", "games", "furniture_assemble", "walking_dogs"],
  #   "transaction_type" => ["lend", "sell", "rent_out", "give_away", "share_for_free", "borrow", "buy", "rent", "trade", "receive", "accept_for_free"]
  # }
  def available_categorization_values
    values = {}
    values["category"] = top_level_categories.collect(&:id)
    values["subcategory"] = subcategories.collect(&:id)
    values["transaction_type"] = transaction_types.collect(&:id)
    return values
  end

  # same as available_categorization_values but returns the models instead of just values
  def available_categorizations
    values = {}
    values["category"] = top_level_categories
    values["subcategory"] = subcategories
    values["transaction_type"] = transaction_types
    return values
  end

  def main_categories
    top_level_categories
  end

  def leaf_categories
    categories.reject { |c| !c.children.empty? }
  end

  # is it possible to pay for this listing via the payment system
  def payment_possible_for?(listing)
    listing.transaction_type.price_field? && payments_in_use?
  end

  def payments_in_use?
    payment_gateway.present?
  end

  # Does this community require that people have registered payout method before accepting requests
  def requires_payout_registration?
    payment_gateway.present? && payment_gateway.requires_payout_registration_before_accept?
  end

  def default_currency
    if available_currencies
      available_currencies.gsub(" ","").split(",").first
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
    payment_gateway.present? && payment_gateway.type == "BraintreePaymentGateway"
  end

  def mangopay_in_use?
    payment_gateway.present? && payment_gateway.type == "Mangopay"
  end

  # Returns the total service fee for a certain listing
  # in the current community (including gateway fee, platform
  # fee and marketplace fee)
  def service_fee_for(listing)
    service_fee = PaymentMath.service_fee(listing.price_cents, commission_from_seller)
    Money.new(service_fee, listing.currency)
  end

  # Price that the seller gets after the service fee is deducted
  def price_seller_gets_for(listing)
    seller_gets = PaymentMath::SellerCommission.seller_gets(listing.price_cents, commission_from_seller)
    Money.new(seller_gets, listing.currency)
  end

  # Return either minimum price defined by this community or the absolute
  # platform default minimum price.
  def absolute_minimum_price(currency)
    Money.new(minimum_price_cents || 100, currency || "EUR")
  end

  def invoice_form_type_for(listing)
    payment_possible_for?(listing) ? payment_gateway.invoice_form_type : "no_form"
  end

  def integrations_in_use?
    plan_level >= BASIC_PLAN
  end

  private

  def initialize_settings
    update_attribute(:settings,{"locales"=>[APP_CONFIG.default_locale]}) if self.settings.blank?
  end
end
