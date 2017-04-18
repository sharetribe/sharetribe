module ActiveSessionsHelper
  module Store
    Session = EntityUtils.define_builder(
      [:id, :uuid, :mandatory, transform_with: UUIDUtils::PARSE_RAW],
      [:person_id, :string, :optional],
      [:community_id, :fixnum, :optional],
      [:refreshed_at, :time, :mandatory],
    )

    class ActiveSession < ActiveRecord::Base
      def self.active_sessions(ttl:)
        where("refreshed_at >= ?", ttl.ago)
      end

      def self.expired_sessions(ttl:)
        where("refreshed_at < ?", ttl.ago)
      end
    end

    module_function

    def create(data)
      id = UUIDUtils.create
      ActiveSession.create(data.merge(id: UUIDUtils.raw(id)))

      id
    end

    def find_active(id:, ttl:)
      active_session =
        ActiveSession
          .active_sessions(ttl: ttl)
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

      ActiveSession
        .update_attributes(session.except(:id))
        .where(id: UUIDUtils.raw(id))
    end

    def delete(id:)
      ActiveSession.delete_all(id: UUIDUtils.raw(id))
    end

    def cleanup(ttl:)
      ActiveSession
        .expired_sessions(ttl: ttl)
        .delete_all
    end

    # private

    def from_model(model)
      if model
        Session.call(EntityUtils.model_to_hash(model))
      end
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

    id = Store.create(
      person_id: user.id,
      community_id: user.community_id,
      refreshed_at: Time.now)

    cookie_session[:db_id] = id.to_s
  end

  def validate_and_refresh(user, warden)
    id = parse_uuid(warden.request.session[:db_id])

    db_session =
      if id
        Store.find_active(id: id, ttl: SESSION_TTL)
      end

    if db_session.blank?
      warden.logout
    elsif db_session[:refreshed_at] < SESSION_REFRESH_INTERVAL.ago
      Store.refresh(id: id)
    end

    # temporary
    if db_session.present?
      populate_missing(user, db_session)
    end
  end

  def destroy(warden)
    id = parse_uuid(warden.request.session[:db_id])

    if id
      Store.delete(id: id)
    end
  end

  # Clean up all expired sessions.
  # This method can be called from the cron/scheduled job
  def cleanup
    Store.cleanup(ttl: SESSION_TTL)
  end

  #
  # temporary
  #
  # These methods are temporary methods that should be removed when
  # the migration period from DB session store to cookie store is over
  #

  def create_from_migrated()
    Store.create(refreshed_at: Time.now)
  end

  def populate_missing(user, db_session)
    if db_session[:person_id].nil? || db_session[:community_id].nil?

      Store.update(db_session.merge(
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
