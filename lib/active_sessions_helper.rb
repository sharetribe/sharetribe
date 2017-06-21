module ActiveSessionsHelper
  module Store
    Session = EntityUtils.define_builder(
      [:id, :uuid, :mandatory, transform_with: UUIDUtils::PARSE_RAW],
      [:person_id, :string, :optional],
      [:community_id, :fixnum, :optional],
      [:refreshed_at, :time, :mandatory])

    class ActiveSession < ApplicationRecord; end

    module_function

    def create(data)
      id = UUIDUtils.create
      ActiveSession.create(data.merge(id: UUIDUtils.raw(id)))

      id
    end

    def find(id:)
      active_session =
        ActiveSession
          .find_by(id: UUIDUtils.raw(id))

      from_model(active_session)
    end

    def refresh(id:)
      ActiveSession
        .find_by(id: UUIDUtils.raw(id))
        .touch(:refreshed_at)
    end

    def delete(id:)
      ActiveSession.where(id: UUIDUtils.raw(id)).delete_all
    end

    def cleanup(ttl:)
      ActiveSession.where("refreshed_at < ?", ttl.ago).delete_all
    end

    # private

    def from_model(model)
      if model
        Session.call(EntityUtils.model_to_hash(model))
      end
    end
  end

  module CacheStore

    EXPIRES_IN = 1.day

    module_function

    def create(data)
      Store.create(data)
    end

    def find(id:)
      # This method returns full data of the Session
      # To save some bytes from the cache store, the
      # full data is not cached, only the refreshed_at
      # timestamp is cached
      Store.find(id: id)
    end

    def find_refreshed_at(id:)
      fetch_refreshed_at(id) {
        Store.find(id: id)&.dig(:refreshed_at)
      }
    end

    def refresh(id:)
      invalidate_refreshed_at(id) {
        Store.refresh(id: id)
      }
    end

    def delete(id:)
      invalidate_refreshed_at(id) {
        Store.delete(id: id)
      }
    end

    def cleanup(ttl:)
      # Clean up doesn't invalidate cache, so make sure
      # the refreshed_at timestamp is checked in the code
      # that uses the fetched session
      Store.cleanup(ttl: ttl)
    end

    # private

    def fetch_refreshed_at(id, &block)
      Rails.cache.fetch(cache_key(id), expires_in: EXPIRES_IN, &block)
    end

    def invalidate_refreshed_at(id, &block)
      block.call if block
      Rails.cache.delete(cache_key(id))
    end

    def cache_key(id)
      "/active_sessions/#{id}"
    end

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

    id = CacheStore.create(
      person_id: user.id,
      community_id: user.community_id,
      refreshed_at: Time.now)

    cookie_session[:db_id] = id.to_s
  end

  def validate_and_refresh(user, warden)
    id = parse_uuid(warden.request.session[:db_id])

    refreshed_at =
      if id
        CacheStore.find_refreshed_at(id: id)
      end

    if refreshed_at.blank? || refreshed_at < SESSION_TTL.ago
      warden.logout
    elsif refreshed_at < SESSION_REFRESH_INTERVAL.ago
      CacheStore.refresh(id: id)
    end

  end

  def destroy(warden)
    id = parse_uuid(warden.request.session[:db_id])

    if id
      CacheStore.delete(id: id)
    end
  end

  # Clean up all expired sessions.
  # This method can be called from the cron/scheduled job
  def cleanup
    logger.info("Cleaning up expired sessions...", :cleanup, { state: :starting })
    begin
      count = CacheStore.cleanup(ttl: SESSION_TTL)
      logger.info("Deleted #{count} expired sessions.", :cleanup, { state: :success, count: count })
    rescue StandardError => e
      logger.info("Failed to clean up expired sessions.", :cleanup, { state: :error, message: e.message })

      # Reraise (calling `raise` without arguments will reraise last error)
      raise
    end
  end

  def logger
    @logger ||= SharetribeLogger.new(:active_sessions)
  end

  #
  # private
  #

  def parse_uuid(id_str)
    if id_str
      UUIDTools::UUID.parse(id_str)
    end
  end
end
