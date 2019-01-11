class Person::OmniauthService
  FACEBOOK = 'facebook'.freeze

  attr_reader :community, :request, :data, :provider
  def initialize(community:, request:, provider:)
    @community = community
    @request = request
    @provider = provider
    @data = request.env["omniauth.auth"].extra.raw_info
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
      "id"  => data.id
    }
  end

  def update_person_provider_uid
    if provider == FACEBOOK
      update_facebook_data
    end
  end

  private

  def members
    community.members_all_statuses
  end

  def person_by_uid
    if provider == FACEBOOK
      members.find_by(facebook_id: data.id)
    end
  end

  def person_by_email
    members.by_email(data.email).first
  end

  def person_is_admin_by_uid
    if provider == FACEBOOK
      Person.is_admin.find_by(facebook_id: data.id)
    end
  end

  def person_is_admin_by_email
    Person.is_admin.by_email(data.email).first
  end

  def update_facebook_data
    person.update_attribute(:facebook_id, data.id) # rubocop:disable Rails/SkipsModelValidations
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

  class Creator
    attr_reader :community, :omniauth
    def initialize(community:, omniauth:)
      @community = community
      @omniauth = omniauth
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
        :facebook_id => omniauth["id"],
        :locale => I18n.locale,
        :test_group_number => 1 + rand(4),
        :password => Devise.friendly_token[0,20],
        community_id: community.id
      }

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
      person
    end
  end
end
