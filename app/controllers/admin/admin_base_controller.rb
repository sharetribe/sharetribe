# This controller is parent for all controllers handling the admin area functions

class Admin::AdminBaseController < ApplicationController

  before_filter :ensure_is_admin

  #Allow admin to access admin panel before email confirmation
  skip_filter :cannot_access_without_confirmation
end
