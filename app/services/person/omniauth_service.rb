class Person::OmniauthService
  FACEBOOK = 'facebook'.freeze
  GOOGLE_OAUTH2 = 'google_oauth2'.freeze
  LINKEDIN = 'linkedin'.freeze
  NAMES = {
    FACEBOOK => 'Facebook',
    GOOGLE_OAUTH2 => 'Google',
    LINKEDIN => 'LinkedIn'
  }.freeze

  attr_reader :community, :request, :logger
  def initialize(community:, request:, logger:)
    @community = community
    @request = request
    @logger = logger
  end

  delegate :person, :person_email_unconfirmed, to: :finder, prefix: false

  def no_ominauth_email?
    email.blank?
  end

  def update_person_provider_uid
    case provider
    when FACEBOOK
      update_facebook_data
    when GOOGLE_OAUTH2
      update_google_data
    when LINKEDIN
      update_linkedin_data
    end
  end

  def create_person
    username = UserService::API::Users.username_from_fb_data(
      username: data.username,
      given_name: info.first_name,
      family_name: info.last_name,
      community_id: community.id)

    person_hash = {
      :username => username,
      :given_name => info.first_name,
      :family_name => info.last_name,
      :locale => I18n.locale,
      :test_group_number => rand(1..4),
      :password => Devise.friendly_token[0,20],
      community_id: community.id
    }
    if facebook?
      person_hash[:facebook_id] = uid
    elsif google_oauth2?
      person_hash[:google_oauth2_id] = uid
    elsif linkedin?
      person_hash[:linkedin_id] = uid
    end


    new_person = nil
    ActiveRecord::Base.transaction do
      new_person = Person.create!(person_hash)
      # We trust that Facebook has already confirmed these and save the user few clicks
      Email.create!(:address => email, :send_notifications => true, :person => new_person, :confirmed_at => Time.zone.now, community_id: community.id)

      new_person.set_default_preferences

      # By default no email consent is given
      new_person.preferences["email_from_admins"] = false
      new_person.save

      CommunityMembership.create(person: new_person, community: community, status: "pending_consent")
    end
    store_picture(new_person) if new_person
    new_person
  end

  def facebook?
    provider == FACEBOOK
  end

  def google_oauth2?
    provider == GOOGLE_OAUTH2
  end

  def linkedin?
    provider == LINKEDIN
  end

  def provider_name
    NAMES[provider]
  end

  def email # rubocop:disable Rails/Delegate
    info.email
  end

  def provider
    @provider ||= request.env["omniauth.auth"]['provider']
  end

  private

  def data
    @data ||= request.env["omniauth.auth"].extra.raw_info
  end

  def uid
    @uid ||= request.env["omniauth.auth"]['uid']
  end

  def info
    @info ||= request.env["omniauth.auth"].info
  end

  def update_facebook_data
    person.update_attribute(:facebook_id, uid) # rubocop:disable Rails/SkipsModelValidations
    store_picture(person)
  end

  def update_google_data
    person.update_attribute(:google_oauth2_id, uid) # rubocop:disable Rails/SkipsModelValidations
    store_picture(person)
  end

  def update_linkedin_data
    person.update_attribute(:linkedin_id, uid) # rubocop:disable Rails/SkipsModelValidations
    store_picture(person)
  end

  def store_picture(new_person)
    if new_person.image_file_size.nil?
      begin
        store_picture_from_provider(new_person)
      rescue StandardError => e
        # We can just catch and log the error, because if the profile picture upload fails
        # we still want to make the user creation pass, just without the profile picture,
        # which user can upload later
        logger.error(e.message, :facebook_new_user_profile_picture_upload_failed, { person_id: new_person.id })
      end
    end
  end

  def finder
    @finder ||= Finder.new(community: community, provider: provider, uid: uid, email: email)
  end

  def store_picture_from_provider(new_person)
    url = if facebook? && new_person.facebook_id
      resp = RestClient.get(
        "https://graph.facebook.com/#{FacebookSdkVersion::SERVER}/#{new_person.facebook_id}/picture?type=large&redirect=false")
      JSON.parse(resp)["data"]["url"]
    elsif google_oauth2? && new_person.google_oauth2_id
      info.image
    elsif linkedin? && new_person.linkedin_id
      info.picture_url
    end
    new_person.picture_from_url(url)
  end

  class Finder
    attr_reader :community, :provider, :uid, :email
    def initialize(community:, provider:, uid:, email:)
      @community = community
      @provider = provider
      @uid = uid
      @email = email
    end

    def person
      return @person if defined?(@person)

      @person = person_by_uid || person_by_email || person_is_admin_by_uid || person_is_admin_by_email
    end

    def person_email_unconfirmed
      return @person_email_unconfirmed if defined?(@person_email_unconfirmed)

      @person_email_unconfirmed = members.by_unconfirmed_email(email).first
    end

    private

    def members
      community.members_all_statuses
    end

    def global_admins
      Person.is_admin
    end

    def person_by_uid
      case provider
      when FACEBOOK
        members.find_by(facebook_id: uid)
      when GOOGLE_OAUTH2
        members.find_by(google_oauth2_id: uid)
      when LINKEDIN
        members.find_by(linkedin_id: uid)
      end
    end

    def person_by_email
      members.by_email(email).first
    end

    def person_is_admin_by_uid
      case provider
      when FACEBOOK
        global_admins.find_by(facebook_id: uid)
      when GOOGLE_OAUTH2
        global_admins.find_by(google_oauth2_id: uid)
      when LINKEDIN
        global_admins.find_by(linkedin_id: uid)
      end
    end

    def person_is_admin_by_email
      global_admins.by_email(email).first
    end
  end

  class SetupPhase
    class << self
      def call(env)
        community = env[:current_marketplace]
        provider = env["omniauth.strategy"].name
        strategy = env["omniauth.strategy"]
        case provider
        when FACEBOOK
          # Facebook setup phase hook, that is used to dynamically set up a omniauth strategy for facebook on customer basis
          strategy.options[:iframe] = true
          strategy.options[:scope] = "public_profile,email"
          strategy.options[:info_fields] = "name,email,last_name,first_name"

          if community.facebook_connect_enabled?
            strategy.options[:client_id] = community.facebook_connect_id || APP_CONFIG.fb_connect_id
            strategy.options[:client_secret] = community.facebook_connect_secret || APP_CONFIG.fb_connect_secret
          else
            # to prevent plain requests to /people/auth/facebook even when "login with Facebook" button is hidden
            strategy.options[:client_id] = ""
            strategy.options[:client_secret] = ""
          end
        when GOOGLE_OAUTH2
          if community.google_connect_enabled?
            strategy.options[:client_id] = community.google_connect_id
            strategy.options[:client_secret] = community.google_connect_secret
          else
            strategy.options[:client_id] = ""
            strategy.options[:client_secret] = ""
          end
        when LINKEDIN
          if community.linkedin_connect_enabled?
            strategy.options[:client_id] = community.linkedin_connect_id
            strategy.options[:client_secret] = community.linkedin_connect_secret
          else
            strategy.options[:client_id] = ""
            strategy.options[:client_secret] = ""
          end
        end
      end
    end
  end
end
