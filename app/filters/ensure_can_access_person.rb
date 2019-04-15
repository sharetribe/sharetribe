class EnsureCanAccessPerson
  attr_reader :param_name, :error_message_key, :allow_admin

  def initialize(param_name, opts = {})
    @param_name = param_name
    @error_message_key = opts[:error_message_key] || "layouts.notifications.you_are_not_authorized_to_do_this"
    @allow_admin = opts[:allow_admin]
  end

  def before(controller)
    current_user = controller.current_user
    current_community = controller.instance_variable_get(:@current_community)
    username = controller.params[param_name]

    allow = current_user && current_user.username == username
    allow ||= (allow_admin && current_user.has_admin_rights?(current_community))
    unless allow
      controller.flash[:error] = I18n.t(error_message_key)
      controller.redirect_to controller.search_path and return
    end
  end
end
