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

  def set_from_model(community: nil, person: nil)
    role =
      if person.nil?
        nil
      elsif person.has_admin_rights?
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

end
