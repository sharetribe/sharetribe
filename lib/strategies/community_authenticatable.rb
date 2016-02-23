require 'devise/strategies/database_authenticatable'

module CommunityAuthenticatable
  class CommunityStrategy < Devise::Strategies::DatabaseAuthenticatable

    def authenticate!
      hashed = false
      person = resolve_person

      if person && (belongs_to_community?(person.id, env[:community_id]) || person.is_admin?) &&
        validate(person){ person.valid_password?(password) }

        hashed = true
        remember_me(person)
        person.after_database_authentication
        success!(person)
      end

      mapping.to.new.password = password if !hashed && Devise.paranoid
      # rubocop:disable Style/SignalException
      fail(:not_found_in_database) unless person
      # rubocop:enable Style/SignalException
    end

    private

    def belongs_to_community?(person_id, community_id)
      CommunityMembership.where("person_id = ? AND community_id = ?", person_id, community_id).present?
    end

    def resolve_person
      if password.present?
        find_by_username_or_email(authentication_hash[:login].downcase)
      end
    end

    def find_by_username_or_email(login)
      Person.find_by(username: login) || Maybe(Email.find_by(address: login)).person.or_else(nil)
    end

  end
end

# for warden, `:community_authenticatable`` is just a name to identify the strategy
Warden::Strategies.add :community_authenticatable, CommunityAuthenticatable::CommunityStrategy

# for devise, there must be a module named 'CommunityAuthenticatable' (name.to_s.classify), and then it looks to warden
# for that strategy. This strategy will only be enabled for models using devise and `:community_authenticatable` as an
# option in the `devise` class method within the model.
Devise.add_module :community_authenticatable, :strategy => true
