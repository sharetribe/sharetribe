require_relative "../../lib/active_sessions_helper"

# This callback is called after the user has been logged in
# (first time for the session)
Warden::Manager.after_authentication do |user, warden, opts|
  ActiveSessionsHelper.create(user, warden)
end

# This callback is called when:
#
# - User logs in (opts[:event] == :authentication, same as `after_authentication`)
# - User is fetched from the session (opts[:event] == :fetch, same as `after_fetch`)
# - User is signed in manually (opts[:event] == :set_user)
#
Warden::Manager.after_set_user do |user, warden, opts|
  if warden.request.session[:in_migration]
    # temporary START
    #
    # This code block can be deleted after the migration period
    # from database -> cookie store is over
    ActiveSessionsHelper.create(user, warden)
    warden.request.session.delete(:in_migration)
    # temporary END
  elsif opts[:event] == :set_user
    # We need to create a active session for users who were
    # manually set. This happens if we call sign_in! manually
    # in controllers, e.g. in PeopleController after user
    # signed up.
    ActiveSessionsHelper.create(user, warden)
  end
end

# This user is called everytime user is fetched from the sesssion
Warden::Manager.after_fetch do |user, warden, opts|
  ActiveSessionsHelper.validate_and_refresh(user, warden)
end

Warden::Manager.before_logout do |user, warden, opts|
  ActiveSessionsHelper.destroy(warden)
end
