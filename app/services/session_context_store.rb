module SessionContextStore

  Context = EntityUtils.define_builder(
    [:marketplace_id, :fixnum],
    [:marketplace_uuid, :uuid],
    [:user_id, :string],
    [:user_uuid, :uuid],
    [:user_role, one_of: [nil, :user, :admin]])

  module_function

  def set(ctx)
    RequestStore[:__session_context] = Context.call(ctx)
  end

  def get
    RequestStore[:__session_context] ||= Context.call({})
  end

  # Resets the store
  #
  # Note: Calling `reset!` is needed only in exceptional cases!
  #       Normally, the underlying RequestStore is reseted after
  #       each request or delayed job
  #
  def reset!
    RequestStore[:__session_context] = nil
  end

  def set_from_model(community: nil, person: nil)
    role =
      if person.nil?
        nil
      elsif community && person.has_admin_rights?(community)
        :admin
      else
        :user
      end

    session_context = {
      marketplace_id: community&.id,
      marketplace_uuid: community&.uuid_object,

      user_id: person&.id,
      user_uuid: person&.uuid_object,
      user_role: role
    }

    set(session_context)
  end

  def set_from_transaction(actor:, tx:)
    marketplace_session_ctx = {
      marketplace_id: tx.community_id,
      marketplace_uuid: tx.community_uuid_object
    }

    user_session_ctx =
      case actor
      when :starter
        {
          user_id: tx.starter_id,
          user_uuid: tx.starter_uuid_object
        }
      when :author
        {
          user_id: tx.listing_author_id,
          user_uuid: tx.listing_author_uuid_object
        }
      when :unknown
        # Unknown user
        {}
      else
        raise ArgumentError.new("Unknown transition actor: #{actor}")
      end

    SessionContextStore.set(marketplace_session_ctx.merge(user_session_ctx))
  end

end
