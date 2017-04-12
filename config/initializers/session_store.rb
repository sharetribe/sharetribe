# Be sure to restart your server when you modify this file.

class ActionDispatch::Session::MigrateToCookieStore < ActionDispatch::Session::CookieStore

  def load_session(req)
    stale_session_check! do
      data = unpacked_cookie_data(req)

      if data["session_id"]
        data = persistent_session_id!(data)
        [data["session_id"], data]
      else
        db_session = find_db_session(req)

        if db_session
          [db_session.session_id, db_session.data]
        else
          data = persistent_session_id!(data)
          [data["session_id"], data]
        end
      end

    end
  end

  def session_exists?(env)
    super(env) || find_db_session(env).present?
  end

  private

  def find_db_session(env)
    req = Rack::Request.new(env)
    session_id = req.cookies[APP_CONFIG.cookie_session_key]
    ActiveRecord::SessionStore::Session.find_by_session_id(session_id)
  end
end

Rails.application.config.session_store(
  :migrate_to_cookie_store,
  key: APP_CONFIG.cookie_session_key,
  expire_after: 6.months, # TODO Is this correct value
  secure: APP_CONFIG.always_use_ssl.to_s.casecmp("true") == 0
)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Rails.application.config.session_store :active_record_store
