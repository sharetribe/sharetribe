require_relative "../../lib/session_helper"

Warden::Manager.after_set_user do |user, warden, opts|
  SessionHelper.validate_and_refresh_ttl(user, warden)
end
