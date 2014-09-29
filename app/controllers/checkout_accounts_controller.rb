class CheckoutAccountsController < ApplicationController
  before_filter do |controller|
    controller.ensure_logged_in "You need to be logged in in order to change payment details."
  end

  skip_filter :dashboard_only

  CheckoutAccountForm = FormUtils.define_form("CheckoutAccountForm", :company_id_or_personal_id, :organization_address, :phone_number, :organization_website)
    .with_validations do
      validates_presence_of :organization_address, :phone_number
      validates_format_of :company_id_or_personal_id, with: /^(\d{7}\-\d)$|^(\d{6}\D\d{3}\w)$/, allow_nil: false
    end

  def new
    redirect_to action: :show and return if @current_user.checkout_account

    @selected_left_navi_link = "payments"
    render(locals: { checkout_account: CheckoutAccountForm.new({ phone_number: @current_user.phone_number }),
                     form_action: person_checkout_account_path(@current_user) })
  end

  def show
    redirect_to action: :new and return unless @current_user.checkout_account

    @selected_left_navi_link = "payments"
    render(locals: {person: @current_user})
  end

  def create
    checkout_account_form = CheckoutAccountForm.new(params[:checkout_account_form])

    if checkout_account_form.valid?
      payment_gateway = @current_community.payment_gateway
      # If updating payout details, check that they are valid
      registering_successful = payment_gateway.register_payout_details(@current_user, checkout_account_form)
      redirect_to action: :show
    else
      flash[:error] = checkout_account_form.errors.full_messages
      render(:new, locals: { checkout_account: checkout_account_form, form_action: person_checkout_account_path(@current_user) })
    end
  end
end
