class EnsureCanAccessPerson

  def initialize(param_name, opts = {})
    @param_name = param_name
    @error_message_key = opts[:error_message_key] || "layouts.notifications.you_are_not_authorized_to_do_this"
  end

  def before(controller)
    current_user = controller.current_user
    username = controller.params[@param_name]

    unless current_user && current_user.username == username
      controller.flash[:error] = I18n.t(@error_message_key)
      controller.redirect_to controller.root and return
    end
  end
end
