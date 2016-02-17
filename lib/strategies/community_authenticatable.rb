require 'devise/strategies/database_authenticatable'

module CommunityAuthenticatable
  class CommunityStrategy < Devise::Strategies::DatabaseAuthenticatable

    def authenticate!
      hashed = false
      person = resolve_person

      if person && (belongs_to_current_community?(person) || person.is_admin?) &&
        validate(person){ hashed = true; person.valid_password?(password) }

        remember_me(person)
        person.after_database_authentication
        success!(person)
      end

      mapping.to.new.password = password if !hashed && Devise.paranoid
      fail(:not_found_in_database) unless person
    end

    private

    def belongs_to_current_community?(person)
      person.communities.pluck(:id).include?(env[:community_id])
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
