# Be sure to restart your server when you modify this file.

require_relative "../../lib/active_sessions_helper"

# Session store to seamlessly migrate from Database store to Cookie store
#
# This session store inherits the Cookie store. It overrides two methods:
#
# - load_session
# - session_exists?
#
# After the migration period from Database store to Cookie store is over,
# this session store can be replaced with the default Cookie store.
#
class ActionDispatch::Session::MigrateToCookieStore < ActionDispatch::Session::CookieStore

  # Load session data from the cookie
  #
  # If session data can't be found from the cookie, it
  # tries to the session data from the database store.
  #
  # If session is found from the database, a new "active session"
  # is created.
  #
  # Old session from the database is deleted.
  #
  def load_session(req)
    stale_session_check! do
      data = unpacked_cookie_data(req)

      if data["session_id"]
        data = persistent_session_id!(data)
        [data["session_id"], data]
      else
        db_session = find_db_session(req)

        if db_session
          session_data = [db_session.session_id, db_session.data.merge(in_migration: true)]
          db_session.destroy

          session_data
        else
          # Create new session using the normal CookieStore
          data = persistent_session_id!(data)
          [data["session_id"], data]
        end
      end

    end
  end

  # Checks if session exists.
  # First if tries to find the session from the cookie. If not found
  # from the cookie, it tries to find it from the database
  def session_exists?(env)
    super(env) || find_db_session(env).present?
  end

  private

  def find_db_session(req)
    session_id = req.cookies[APP_CONFIG.cookie_session_key]
    ActiveRecord::SessionStore::Session.find_by_session_id(session_id)
  end
end

Rails.application.config.session_store(
  :migrate_to_cookie_store,
  key: APP_CONFIG.cookie_session_key,
  expire_after: ActiveSessionsHelper::SESSION_TTL,
  secure: APP_CONFIG.always_use_ssl.to_s.casecmp("true") == 0
)

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# Rails.application.config.session_store :active_record_store
