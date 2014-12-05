class PasswordsController < Devise::PasswordsController
  skip_filter :single_community_only

  layout :choose_layout

  private

  def choose_layout
    on_dashboard? ? "dashboard" : "application"
  end

end
