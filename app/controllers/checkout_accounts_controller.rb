class CheckoutAccountsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in "You need to be logged in in order to change payment details."
  end

  skip_filter :dashboard_only

  def new
    @selected_left_navi_link = "payments"
    render locals: { checkout_account: CheckoutAccountForm.new({ phone_number: @current_user.phone_number }),
                     form_action: person_checkout_account_path(@current_user) }
  end

  def show
    redirect_to action: :new and return unless CheckoutAccount.find_by_person_id(@current_user)

    @selected_left_navi_link = "payments"
    render locals: {person: @current_user}
  end

  def create
    checkoutAccountForm = CheckoutAccountForm.new(params[:checkout_account_form])
    if checkoutAccountForm.valid?
      payment_gateway = @current_community.payment_gateway
      # If updating payout details, check that they are valid
      registering_successful = payment_gateway.register_payout_details(@current_user, checkout_account_form)
      redirect_to :back and return unless registering_successful
    end
  end

  private
  CheckoutAccountForm = Util::FormUtils.define_form("CheckoutAccountForm", :company_id, :organization_address, :phone_number, :organization_website)
    .with_validations do
      validates_presence_of :organization_address, :phone_number, :organization_website
      validates_format_of :company_id, with: /^(\d{7}\-d)?$/, allow_nil: true
    end
end
