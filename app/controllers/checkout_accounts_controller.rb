class CheckoutAccountsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in "You need to be logged in in order to change payment details."
  end

  skip_filter :dashboard_only

  def new
    @selected_left_navi_link = "payments"
    render locals: {person: @current_user}
  end

  def show
    @selected_left_navi_link = "payments"
    render locals: {person: @current_user}
  end

end
