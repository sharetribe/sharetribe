module UserService::API
  module Users

    module_function

    # TODO make people controller use this method too
    # The challenge for that is the devise connections
    def create_user(user_hash, community_id, invitation_id = nil)

      raise ArgumentError.new("Email #{user_hash[:email]} is already in use.") unless Email.email_available?(user_hash[:email], community_id)

      begin
        username = generate_username(user_hash[:given_name], user_hash[:family_name], community_id)
        locale = user_hash[:locale] || APP_CONFIG.default_locale # don't access config like this, require to be passed in in ctor

        person = Person.new(
          given_name: user_hash[:given_name],
          family_name: user_hash[:family_name],
          password: user_hash[:password],
          username: username,
          locale: locale,
          test_group_number: 1 + rand(4),
          community_id: community_id)

        email = Email.new(person: person, address: user_hash[:email].downcase, send_notifications: true, community_id: community_id)

        person.emails << email
        person.inherit_settings_from(Community.find(community_id)) if community_id

        ActiveRecord::Base.transaction do
          person.save!
          person.set_default_preferences

          user = from_model(person)

          # The first member will be made admin
          make_user_a_member_of_community(user[:id], community_id, invitation_id)

          email = Email.find_by_person_id!(user[:id])
          community = Community.find(community_id)

          # send email confirmation (unless disabled for testing environment)
          if APP_CONFIG.skip_email_confirmation
            email.confirm!
          else
            Email.send_confirmation(email, community)
          end

          Result::Success.new(user)
        end
      rescue
        Result::Error.new("Failed to create a new user")
      end
    end

    def make_user_a_member_of_community(user_id, community_id, invitation_id=nil)

      # Fetching the models would not be necessary, but that validates the ids
      user = Person.find(user_id)
      community = Community.find(community_id)

      membership = CommunityMembership.new(:person => user, :community => community, :consent => community.consent)
      membership.status = "pending_email_confirmation"
      membership.invitation = Invitation.find(invitation_id) if invitation_id.present?

      # If the community doesn't have any members, make the first one an admin
      if community.members.count == 0
        membership.admin = true
      end
      membership.save!
    end

    def from_model(person)
      hash = HashUtils.compact(
        EntityUtils.model_to_hash(person).merge({
            # This is a spot to modify hash contents if needed
          }))
      return UserService::API::DataTypes.create_user(hash)
    end

    def username_from_fb_data(username:, given_name:, family_name:, community_id:)
      base = Maybe(
          Maybe(username)
          .or_else(Maybe(given_name).strip.or_else("") + Maybe(family_name).strip()[0].or_else(""))
        )
        .to_url
        .delete('-')
        .or_else("fb_name_missing")[0...18]

      generate_username_from_base(base, community_id)
    end

    def replace_with_default_locale(community_id:, locales:, default_locale:)
      Person.where(community_id: community_id, locale: locales).update_all(locale: default_locale)
    end

    # private

    def generate_username(given_name, family_name, community_id)
      base = (given_name.strip + family_name.strip[0]).to_url.delete('-')[0...18]
      generate_username_from_base(base, community_id)
    end
    private_class_method :generate_username

    def generate_username_from_base(base, community_id)
      taken = fetch_taken_usernames(base, community_id)
      reserved = Person.username_blacklist.concat(taken)
      gen_free_name(base, reserved)
    end
    private_class_method :generate_username_from_base

    def fetch_taken_usernames(base, community_id)
      Person.where("username LIKE :prefix AND community_id = :community_id",
                   prefix: "#{base}%", community_id: community_id).pluck(:username)
    end
    private_class_method :fetch_taken_usernames

    def gen_free_name(base, reserved)
      (1..100000).reduce([base, ""]) do |(base_name, postfix), next_postfix|
        return (base_name + postfix) unless reserved.include?(base_name + postfix) || (base_name + postfix).length < 3
        [base_name, next_postfix.to_s]
      end
    end
    private_class_method :gen_free_name
  end
end
