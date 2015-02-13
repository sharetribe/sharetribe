module UserService::API
  module AuthTokens

    module_function

    # Creates a token and returns the token string
    def create_login_token(user_id)
      auth_token = AuthToken.create!(:person_id => user_id, :expires_at => 10.minutes.from_now, :token_type => "login")
      return { token: auth_token.token }
    end

    def use_token_for_login(token_string)
      return nil if token_string.blank?
      if t = AuthToken.where(token: token_string).first
        t.last_use_attempt = Time.now # record the usage attempt
        if t.expires_at > Time.now && t.usages_left > 0 && t.token_type == "login"
          # Token is valid for login
          t.usages_left = t.usages_left - 1
          t.save
          return UserService::API::Users::from_model(t.person)
        end
      end
    end

  end
end
