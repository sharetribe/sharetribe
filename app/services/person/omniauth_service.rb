class Person::OmniauthService
  FACEBOOK = 'facebook'.freeze
  GOOGLE_OAUTH2 = 'google_oauth2'.freeze

  attr_reader :community, :request, :logger
  def initialize(community:, request:, logger:)
    @community = community
    @request = request
    @logger = logger
  end

  def person
    return @person if defined?(@person)
    @person = person_by_uid || person_by_email || person_is_admin_by_uid || person_is_admin_by_email
  end

  def person_email_unconfirmed
    return @person_email_unconfirmed if defined?(@person_email_unconfirmed)
    @person_email_unconfirmed = members.by_unconfirmed_email(data.email).first
  end

  def no_ominauth_email?
    data.email.blank?
  end

  def session_data
    {
      "provider" => provider,
      "email" => data.email,
      "given_name" => data.first_name,
      "family_name" => data.last_name,
      "username" => data.username,
      "id"  => uid
    }
  end

  def update_person_provider_uid
    case provider
    when FACEBOOK
      update_facebook_data
    when GOOGLE_OAUTH2
      update_google_data
    end
  end

  private

  def data
    @data ||= request.env["omniauth.auth"].extra.raw_info
  end

  def uid
    @uid ||= request.env["omniauth.auth"]['uid']
  end

  def provider
    @provider ||= request.env["omniauth.auth"]['provider']
  end

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
    end
  end

  def person_by_email
    members.by_email(data.email).first
  end

  def person_is_admin_by_uid
    case provider
    when FACEBOOK
      global_admins.find_by(facebook_id: uid)
    when GOOGLE_OAUTH2
      global_admins.find_by(google_oauth2_id: uid)
    end
  end

  def person_is_admin_by_email
    global_admins.by_email(data.email).first
  end

  def update_facebook_data
    person.update_attribute(:facebook_id, uid) # rubocop:disable Rails/SkipsModelValidations
    if person.image_file_size.nil?
      begin
        person.store_picture_from_facebook!
      rescue StandardError => e
        # We can just catch and log the error, because if the profile picture upload fails
        # we still want to make the user creation pass, just without the profile picture,
        # which user can upload later
        logger.error(e.message, :facebook_existing_user_profile_picture_upload_failed, { person_id: person.id })
      end
    end
  end

  def update_google_data
    person.update_attribute(:google_oauth2_id, uid) # rubocop:disable Rails/SkipsModelValidations
  end

  class Creator
    attr_reader :community, :omniauth, :logger, :provider
    def initialize(community:, omniauth:, logger:)
      @community = community
      @omniauth = omniauth
      @logger = logger
      @provider = omniauth["provider"]
    end

    def create_person
      username = UserService::API::Users.username_from_fb_data(
        username: omniauth["username"],
        given_name: omniauth["given_name"],
        family_name: omniauth["family_name"],
        community_id: community.id)

      person_hash = {
        :username => username,
        :given_name => omniauth["given_name"],
        :family_name => omniauth["family_name"],
        :locale => I18n.locale,
        :test_group_number => 1 + rand(4),
        :password => Devise.friendly_token[0,20],
        community_id: community.id
      }
      if facebook?
        person_hash[:facebook_id] = omniauth["id"]
      elsif google_oauth2?
        person_hash[:google_oauth2_id] = omniauth["id"]
      end


      person = nil
      ActiveRecord::Base.transaction do
        person = Person.create!(person_hash)
        # We trust that Facebook has already confirmed these and save the user few clicks
        Email.create!(:address => omniauth["email"], :send_notifications => true, :person => person, :confirmed_at => Time.zone.now, community_id: community.id)

        person.set_default_preferences

        # By default no email consent is given
        person.preferences["email_from_admins"] = false
        person.save

        CommunityMembership.create(person: person, community: community, status: "pending_consent")
      end
      store_picture(person)
      person
    end

    def facebook?
      provider == Person::OmniauthService::FACEBOOK
    end

    def google_oauth2?
      provider == Person::OmniauthService::GOOGLE_OAUTH2
    end

    private

    def store_picture(person)
      if facebook?
        begin
          person.store_picture_from_facebook!
        rescue StandardError => e
          # We can just catch and log the error, because if the profile picture upload fails
          # we still want to make the user creation pass, just without the profile picture,
          # which user can upload later
          logger.error(e.message, :facebook_new_user_profile_picture_upload_failed, { person_id: person.id })
        end
      end
    end
  end

  class SetupPhase
    attr_reader :community, :params, :request
    def initialize(community:, params:, request:)
      @community = community
      @params = params
      @request = request
    end

    def run
      case params[:provider]
      when Person::OmniauthService::FACEBOOK
        # Facebook setup phase hook, that is used to dynamically set up a omniauth strategy for facebook on customer basis
        request.env["omniauth.strategy"].options[:iframe] = true
        request.env["omniauth.strategy"].options[:scope] = "public_profile,email"
        request.env["omniauth.strategy"].options[:info_fields] = "name,email,last_name,first_name"

        if community.facebook_connect_enabled?
          request.env["omniauth.strategy"].options[:client_id] = community.facebook_connect_id || APP_CONFIG.fb_connect_id
          request.env["omniauth.strategy"].options[:client_secret] = community.facebook_connect_secret || APP_CONFIG.fb_connect_secret
        else
          # to prevent plain requests to /people/auth/facebook even when "login with Facebook" button is hidden
          request.env["omniauth.strategy"].options[:client_id] = ""
          request.env["omniauth.strategy"].options[:client_secret] = ""
          request.env["omniauth.strategy"].options[:client_options][:authorize_url] = login_url
          request.env["omniauth.strategy"].options[:client_options][:site_url] = login_url
        end
      when Person::OmniauthService::GOOGLE_OAUTH2
        if community.google_connect_enabled?
          request.env["omniauth.strategy"].options[:client_id] = community.google_connect_id
          request.env["omniauth.strategy"].options[:client_secret] = community.google_connect_secret
        else
          request.env["omniauth.strategy"].options[:client_id] = ""
          request.env["omniauth.strategy"].options[:client_secret] = ""
        end
      end
    end
  end
end
