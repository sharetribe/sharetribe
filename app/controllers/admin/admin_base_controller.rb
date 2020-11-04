# This controller is parent for all controllers handling the admin area functions

class Admin::AdminBaseController < ApplicationController

  before_action :ensure_is_admin

  #Allow admin to access admin panel before email confirmation
  skip_before_action :cannot_access_without_confirmation

  before_action :admin2_banner

  def admin2_banner
    @admin2_banner = true
  end
end
