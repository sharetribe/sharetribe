class PasswordsController < Devise::PasswordsController
  skip_filter :dashboard_only, :single_community_only

  layout :choose_layout

  private

  def choose_layout
    on_dashboard? ? "dashboard" : "application"
  end

end
