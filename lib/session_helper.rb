module SessionHelper

  # Time-to-live
  SESSION_TTL = 1.month

  # How often the TTL gets refreshed.
  # For performance reasons, we don't want to refresh TTL
  # on each request
  SESSION_TTL_REFRESH_INTERVAL = 1.day

  module_function

  def validate_and_refresh_ttl(user, warden)
    session = warden.request.session

    if session.key?(:ttl) && session[:ttl] < SESSION_TTL.ago
      warden.logout
    elsif !session.key?(:ttl) || session[:ttl] < SESSION_TTL_REFRESH_INTERVAL.ago
      session[:ttl] = Time.now
    end
  end
end
