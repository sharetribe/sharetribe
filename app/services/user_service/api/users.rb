module UserService::API
  module Users

    module_function

    def create_user_with_membership(user_hash, community_id, invitation_id = nil)

      user = create_user(user_hash, community_id)

      # The first member will be made admin
      MarketplaceService::API::Memberships::make_user_a_member_of_community(user[:id], community_id, invitation_id)

      email = Email.find_by_person_id!(user[:id])
      community = Community.find(community_id)

      # send email confirmation (unless disabled for testing environment)
      if APP_CONFIG.skip_email_confirmation
        email.confirm!
      else
        Email.send_confirmation(email, community.full_domain, community)
      end

      return user
    end

    # TODO make people controller use this method too
    # The challenge for that is the devise connections
    #
    # Create a new user by opts and optional current community
    def create_user(opts, community_id = nil)
      raise ArgumentError.new("Email #{opts[:email]} is already in use.") unless Email.email_available?(opts[:email])

      username = generate_username(given_name: opts[:given_name], family_name: opts[:family_name])
      locale = opts[:locale] || APP_CONFIG.default_locale # don't access config like this, require to be passed in in ctor

      person = Person.new(
        given_name: opts[:given_name],
        family_name: opts[:family_name],
        password: opts[:password],
        username: username,
        locale: locale,
        test_group_number: 1 + rand(4))

      email = Email.new(person: person, address: opts[:email].downcase, send_notifications: true)

      person.emails << email
      person.inherit_settings_from(Community.find(community_id)) if community_id
      person.save!
      person.set_default_preferences

      return from_model(person)
    end


    # Privates

    def from_model(person)
      hash = HashUtils.compact(
        EntityUtils.model_to_hash(person).merge({
          # This is a spot to modify hash contents if needed
          }))
      return UserService::API::DataTypes::create_user(hash)
    end

    def generate_username(given_name:, family_name:)
      base = (given_name.strip + family_name.strip[0]).to_url.gsub(/-/, "")[0...18]
      gen_free_name(base, fetch_blacklist(base))
    end

    def username_from_fb_data(username:, given_name:, family_name:)
      base = Maybe(
          Maybe(username)
          .or_else(Maybe(given_name).strip.or_else("") + Maybe(family_name).strip()[0].or_else(""))
        )
        .to_url
        .gsub(/-/, "")
        .or_else("fb_name_missing")[0...18]

      gen_free_name(base, fetch_blacklist(base))
    end


    def fetch_blacklist(base)
      taken = Person.where("username LIKE :prefix", prefix: "#{base}%").pluck(:username)
      Person.username_blacklist.concat(taken)
    end

    def gen_free_name(base, blacklist)
      (1..100000).reduce([base, ""]) do |(base_name, postfix), next_postfix|
        return (base_name + postfix) unless blacklist.include?(base_name + postfix)
        [base_name, next_postfix.to_s]
      end
    end

  end

end
