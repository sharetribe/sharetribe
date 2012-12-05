class Community < ActiveRecord::Base

  has_many :community_memberships, :dependent => :destroy 
  has_many :members, :through => :community_memberships, :source => :person, :foreign_key => :member_id
  has_many :invitations, :dependent => :destroy
  has_many :news_items, :dependent => :destroy
  has_many :polls, :dependent => :destroy
  has_many :event_feed_events, :dependent => :destroy
  has_one :location, :dependent => :destroy
  
  has_and_belongs_to_many :listings
  
  VALID_CATEGORIES = ["company", "university", "association", "neighborhood", "congregation", "town", "apartment_building", "other"]
  
  validates_length_of :name, :in => 2..50
  validates_length_of :domain, :in => 2..50
  validates_format_of :domain, :with => /^[A-Z0-9_-]*$/i
  validates_uniqueness_of :domain
  validates_length_of :slogan, :in => 2..100, :allow_nil => true
  validates_length_of :description, :in => 2..500, :allow_nil => true
  validates_inclusion_of :category, :in => VALID_CATEGORIES
  
  # The settings hash contains some community specific settings:
  # locales: which locales are in use, the first one is the default
    
  serialize :settings, Hash
  
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
    admins.collect { |p| p.email }
  end
  
  # If community name has several words, add an extra space
  # to the end to make Finnish translation look better.
  def name_with_separator(locale)
    (name.include?(" ") && locale.to_s.eql?("fi")) ? "#{name} " : name
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
      member.send_confirmation_instructions
      
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
    reserved_names = %w{ www wiki mail calendar doc docs admin dashboard translate alpha beta gamma test developer community tribe git partner partners global sharetribe share dev st aalto ospn kassi video photos fi fr cl gr us usa subdomain abbesses alesia alexandredumas almamarceau anatolefrance antony anvers argentine artsetmetiers asnieresgennevilliers assembleenationale aubervillierspantin avenueemilezola avron balard barbesrochechouart basiliquedesaintdenis bastille belair belleville berault bercy bibliothequefrancoismitterrand billancourt birhakeim blanche bobignypablopicasso bobignypantin boissiere bolivar bonnenouvelle botzaris boucicaut boulognejeanjaures boulognepontdesaintcloud bourse breguetsabin brochant butteschaumont buzenval cadet cambronne campoformio cardinallemoine carrefourpleyel censierdaubenton champselyseesclemenceau chardonlagache charentonecoles charlesdegaulleetoile charlesmichels charonne chateaudeau chateaudevincennes chateaulandon chateaurouge chatelet chatillonmontrouge chausseedantin cheminvert chevaleret cite clunylasorbonne colonelfabien commerce concorde convention corentincariou corentincelton corvisart courcelles couronnes coursaintemilion creteillechat creteilprefecture creteiluniversite crimee croixdechavaux danube daumesnil denfertrochereau dugommier dupleix duroc ecolemilitaire ecoleveterinaire edgarquinet eglisedauteuil eglisedepantin esplanadedeladefense etiennemarcel europe exelmans faidherbechaligny falguiere felixfaure fillesducalvaire fortdaubervilliers franklinroosevelt funiculairegarebasse funiculairegarehaute gabrielperi gaite gallieni gambetta garedausterlitz garedelest garedelyon garedunord garibaldi georgev glaciere goncourt grandsboulevards guymoquet havrecaumartin hoche hoteldeville iena invalides jacquesbonsergent jasmin jaures javelandrecitroen jourdain julesjoffrin jussieu kleber lachapelle lacourneuve8mai1945 ladefense lafourche lamarckcaulaincourt lamottepicquetgrenelle lamuette latourmaubourg laumiere ledrurollin lekremlinbicetre lepeletier lesagnettes lesgobelins leshalles lessablons liberte liege louisblanc louisemichel lourmel louvrerivoli mabillon madeleine mairiedeclichy mairiedemontreuil mairiedesaintouen mairiedeslilas mairiedissy mairiedivry maisonblanche maisonsalfortlesjuilliottes maisonsalfortstade malakoffplateaudevanves malakoffrueetiennedolet malesherbes maraichers marcadetpoissonniers marcelsembat marxdormoy maubertmutualite menilmontant michelangeauteuil michelangemolitor michelbizot mirabeau miromesnil monceau montgallet montparnassebienvenue moutonduvernet nation nationale notredamedelorette notredamedeschamps oberkampf odeon olympiades opera orlyouest orlysud ourcq palaisroyal parmentier passy pasteur pelleport pereire perelachaise pernety philippeauguste picpus pierreetmariecurie pigalle placedeclichy placedesfites placeditalie placemonge plaisance pointedulac poissonniere pontdelevalloisbecon pontdeneuilly pontdesevres pontmarie pontneuf portedauphine portedauteuil portedebagnolet portedechamperret portedecharenton portedechoisy portedeclichy portedeclignancourt portedelachapelle portedelavillette portedemontreuil portedepantin portedesaintcloud portedesaintouen portedeslilas portedevanves portedeversailles portedevincennes porteditalie portedivry portedoree portedorleans portemaillot presaintgervais pyramides pyramides pyrenees quaidelagare quaidelarapee quatreseptembre rambuteau ranelagh raspail reaumursebastopol rennes republique reuillydiderot richardlenoir richelieudrouot riquet robespierre rome ruedelapompe ruedesboulets ruedubac ruesaintmaur saintambroise saintaugustin saintdenisportedeparis saintdenisuniversite saintfargeau saintfrancoisxavier saintgeorges saintgermaindespres saintjacques saintlazare saintmande saintmarcel saintmichel saintpaul saintphilippeduroule saintplacide saintsebastienfroissart saintsulpice segur sentier sevresbabylone sevreslecourbe simplon solferino stalingrad strasbourgsaintdenis sullymorland telegraphe temple ternes tolbiac trinitedestiennedorves trocadero tuileries vaneau varenne vaugirard vavin victorhugo villejuifleolagrange villejuiflouisaragon villejuifpaulvaillantcouturier villiers volontaires voltaire wagram}
    ! (reserved_names.include?(domain) || find_by_domain(domain).present?)
  end
  
  def self.find_by_email_ending(email)
    Community.all.each do |community|
      return community if community.allowed_emails && community.email_allowed?(email)
    end
    return nil
  end
  
  def email_allowed?(email)
    return true unless allowed_emails.present?
    
    allowed = false
    allowed_array = allowed_emails.split(",")
    allowed_array.each do |allowed_domain_or_address|
      allowed_domain_or_address.strip!
      allowed_domain_or_address.gsub!('.', '\.') #change . to be \. to only match a dot, not any char
      if email =~ /#{allowed_domain_or_address}$/
        allowed = true
        break
      end
    end
    return allowed
  end
  
  def new_members_during_last(time)
    community_memberships.where(:created_at => time.ago..Time.now).collect(&:person)
  end
  
  #returns full domain without protocol
  def full_domain
    "#{self.domain}.#{APP_CONFIG.domain}"
  end

  def self.find_by_allowed_email(email)
    email_ending = "@#{email.split('@')[1]}"
    where("allowed_emails LIKE '%#{email_ending}%'")
  end
  
  # Check if communities with this category are email restricted
  def self.email_restricted?(community_category)
    ["company", "university"].include?(community_category)
  end
  
  # Returns all the people who are admins in at least one tribe.
  def self.all_admins
    Person.joins(:community_memberships).where("community_memberships.admin = '1'").group("people.id")
  end

end
