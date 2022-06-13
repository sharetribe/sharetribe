require_relative "../../lib/active_sessions_helper"

Warden::Manager.after_authentication do |user, warden, opts|
  ActiveSessionsHelper.create(user, warden)
end

Warden::Manager.after_set_user do |user, warden, opts|
  ActiveSessionsHelper.validate_and_refresh(user, warden)
end

Warden::Manager.before_logout do |user, warden, opts|
  ActiveSessionsHelper.destroy(warden)
end
