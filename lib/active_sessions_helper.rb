module ActiveSessionsHelper
  class ActiveSession < ActiveRecord::Base
    self.primary_key = "session_id"
  end

  # Time-to-live
  SESSION_TTL = 1.month

  # How often the session gets refreshed.
  # For performance reasons, we don't want to refresh TTL
  # on each request
  SESSION_REFRESH_INTERVAL = 1.day

  module_function

  #
  # public
  #

  def create(user, warden)
    cookie_session = warden.request.session
    sid = UUIDUtils.create

    ActiveSession.create(
      session_id: UUIDUtils.raw(sid),
      person_id: user.id,
      community_id: user.community_id,
      refreshed_at: Time.now)

    cookie_session[:db_sid] = sid.to_s
  end

  def validate_and_refresh(user, warden)
    cookie_session = warden.request.session
    db_session = active_sessions.find_by(session_id: UUIDUtils.raw(UUIDTools::UUID.parse(cookie_session[:db_sid])))

    if db_session.nil?
      warden.logout
    elsif db_session.refreshed_at < SESSION_REFRESH_INTERVAL.ago
      db_session.touch(:refreshed_at)
    end

    # temporary
    if db_session.present?
      populate_missing(user, db_session)
    end
  end

  def destroy(warden)
    cookie_session = warden.request.session
    ActiveSession.delete_all(session_id: UUIDUtils.raw(UUIDTools::UUID.parse(cookie_session[:db_sid])))
  end

  # Clean up all expired sessions.
  # This method can be called from the cron/scheduled job
  def cleanup
    expired_sessions.delete_all
  end

  #
  # temporary
  #
  # These methods are temporary methods that should be removed when
  # the migration period from DB session store to cookie store is over
  #

  def create_from_migrated()
    sid = UUIDUtils.create

    ActiveSession.create(
      session_id: UUIDUtils.raw(sid),
      refreshed_at: Time.now)
  end

  def populate_missing(user, db_session)
    if db_session.person_id.nil? || db_session.community_id.nil?
      db_session.update_attributes(person_id: user.id, community_id: user.community_id)
    end
  end

  #
  # private
  #

  def active_sessions
    ActiveSession.where("refreshed_at >= ?", SESSION_TTL.ago)
  end

  def expired_sessions
    ActiveSession.where("refreshed_at < ?", SESSION_TTL.ago)
  end
end
