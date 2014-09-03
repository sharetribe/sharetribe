class CheckoutAccountsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in "You need to be logged in in order to change payment details."
  end

  skip_filter :dashboard_only

  def new
    @selected_left_navi_link = "payments"
    render locals: {checkout_account: build_checkout_account, form_action: person_checkout_account_path(@current_user)}
  end

  def show
    @selected_left_navi_link = "payments"
    render locals: {person: @current_user}
  end

  def create
    payment_gateway = @current_community.payment_gateway

    # If updating payout details, check that they are valid
    checkout_param_keys = [:company_id, :organization_address, :phone_number, :organization_website]
    registering_successful = self.register_payout(payment_gateway, params[:checkout_account], checkout_param_keys, @person)
    redirect_to :back and return unless registering_successful
  end

  private
  #TODO: Remove during refactoring!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  def register_payout(payment_gateway, person_params, payment_param_keys, person)
    begin
      payment_gateway.register_payout_details(person)
    rescue => e
      flash[:error] = e.message
      return false
    end
  end

  def build_checkout_account
    CheckoutAccount.new
  end

end
