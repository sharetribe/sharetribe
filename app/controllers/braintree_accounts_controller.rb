class BraintreeAccountsController < ApplicationController

  before_filter do |controller|
    # FIXME Change copy text
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_change_profile_settings")
  end

  skip_filter :dashboard_only

  # Local filters
  before_filter :fetch_braintree_account, :only => [ :edit, :update ]
  before_filter :ensure_authorized, :only => [ :edit, :update ]

  def create
    BraintreeAccount.create(params[:braintree_account])
    redirect_to payments_person_settings_path(@current_user)
  end

  def update
    @current_braintree_account.update_attributes(params[:braintree_account])
    redirect_to payments_person_settings_path(@current_user)
  end

  #
  # Take @current_braintree_account and it is nil, user is not authorized
  #
  def ensure_authorized
    if @current_braintree_account.nil?
      # FIX COPY TEXT
      flash[:error] = t("layouts.notifications.only_listing_author_can_edit_a_listing")
      redirect_to and return
    end
  end

  #
  # Set @current_braintree_account by params id
  #
  def fetch_braintree_account
    id = params[:id]
    @current_braintree_account = BraintreeAccount.find_by_id_and_person_id(id, @current_user.id)
  end
end