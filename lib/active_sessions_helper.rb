module ActiveSessionsHelper
  module Store
    Session = EntityUtils.define_builder(
      [:id, :uuid, :mandatory, transform_with: UUIDUtils::PARSE_RAW],
      [:person_id, :string, :optional],
      [:community_id, :fixnum, :optional],
      [:refreshed_at, :time, :mandatory],
    )

    class ActiveSession < ActiveRecord::Base; end

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

    def update(session)
      id = session[:id]

      # If you need to update refreshed_at, use refresh() method
      ActiveSession
        .update(UUIDUtils.raw(id), session.except(:id, :refreshed_at))
    end

    def delete(id:)
      ActiveSession.delete_all(id: UUIDUtils.raw(id))
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

    def update(session)
      # Update doesn't update refreshed_at, so no need to invalidate
      Store.update(session)
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
      "/active_sessions/#{id.to_s}"
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

    # temporary start
    # remove this after db -> cookie migration period is over
    if refreshed_at.present?
      populate_missing(user, id)
    end
    # temporary end

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
    CacheStore.cleanup(ttl: SESSION_TTL)
  end

  #
  # temporary
  #
  # These methods are temporary methods that should be removed when
  # the migration period from DB session store to cookie store is over
  #

  def create_from_migrated()
    CacheStore.create(refreshed_at: Time.now)
  end

  def populate_missing(user, id)
    db_session = CacheStore.find(id: id)

    if db_session.present? && (db_session[:person_id].nil? || db_session[:community_id].nil?)
      CacheStore.update(db_session.merge(
                          person_id: user.id,
                          community_id: user.community_id))
    end
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
