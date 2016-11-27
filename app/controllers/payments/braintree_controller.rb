class Payments::BraintreeController < ApplicationController
  include ActionView::Helpers::TagHelper
  include ActionView::Context
  SERVICE_FEE = "0"
  
  # before_action :generate_client_token, only: [:new]
  before_action :set_listing, only: [:purchase]
  def new
    if @current_user.is_seller?
      render_to_root("The page you are trying to access is no more available.") and return
    end
  end

  def create
    result = Braintree::MerchantAccount.create(merchant_account_params(params))

    if result.success?
      user_attributes = {
          sub_merchant_account_status: result.merchant_account.status,
          sub_merchant_id: result.merchant_account.id
      }
      @current_user.update_attributes(user_attributes)
      redirect_to new_listing_path, notice: "Your are now a valid customer"
    else
      @transaction_errors = result.errors
      render :new
    end
  end

  def purchase

    # Create braintree customer if it's not already
    unless @current_user.is_buyer?
      result = @current_user.make_customer(params)
      if result.success?
				@current_user.update_attribute(:braintree_customer_id, result.customer.id)
			else
        flash[:error] = @transaction_errors.map{|error| content_tag(:li, error.message)}
        redirect_to listing_path(@listing.id) and return
      end
    end

    # Redirect back if listing author/owner does not have a sub merchant ID
    unless @listing.author.is_seller? or @listing.author.active_merchant?
      render_to_root
      return false
    end

    # Perform Transaction
    cost = (@listing.price_cents/100) # Cents to $
    result = Braintree::Transaction.sale(transaction_params(@listing.author, @current_user, cost))
    if result.success?
      flash[:notice] = "Thank you for Purchasing Item."
      redirect_to "/"
    else
      @transaction_errors = result.errors
      flash[:error] = @transaction_errors.map{|error| content_tag(:li, error.message)}
      redirect_to listing_path(@listing.id)
    end
  end
  
  # This is post action only used by Braintree Webhooks
  # This is to ensure that those sub merchant accounts which are approved by braintree
  # must be updated in application database
  
  # Braintree hits this action every hour in 24 hours after sub merchant created
  def braintree_webhook
    bt_signature = params["bt_signature"]
    bt_payload   = params["bt_payload"]
    
    notification = Braintree::WebhookNotification.parse(
        bt_signature,
        bt_payload
    )

    code = 200
    msg = "Success"
    
    if notification.kind.to_s == Braintree::WebhookNotification::Kind::SubMerchantAccountApproved
      merchant = Person.find_by_sub_merchant_id(notification.merchant_account.id)
  
      if merchant.sub_merchant_account_status != "active"
        merchant.update_attribute(:sub_merchant_account_status, notification.merchant_account.status)
      end
    end

    if notification.kind == Braintree::WebhookNotification::Kind::SubMerchantAccountDeclined
      logger.info notification.message
      code = 403
      msg  = "Forbidden"
    end
    
    render plain: msg, status: code
  end

  private

  def set_listing
    begin
      @listing = Listing.find(params[:listing_id])
      # @current_user = Person.find(params[:person_id]) # In case we couldn't find current_user
    rescue ActiveRecord::RecordNotFound
      render_to_root("Can't find listing. Try again later")
    end
  end

  def render_to_root(msg = "There is something wrong. Contact Tech Support")
    flash[:error] = msg
    redirect_to "/" and return
  end

  def generate_client_token
    if @current_user.is_buyer?
      gon.client_token = Braintree::ClientToken.generate(customer_id: @current_user.braintree_customer_id)
    else
      gon.client_token = Braintree::ClientToken.generate
    end
  end

  def transaction_params(seller, buyer, price)
    transaction_params = {
      :amount => price,
      :merchant_account_id => seller.sub_merchant_id, #sub merchant Id
      :payment_method_nonce => params[:payment_method_nonce],
      :customer_id => buyer.braintree_customer_id,
      :options => {
          :submit_for_settlement => true,
          :store_in_vault_on_success => true
      }
    }

    if params[:payment_method_type] != "PayPalAccount"
      transaction_params[:service_fee_amount] = SERVICE_FEE
    end
    
    # !seller.has_admin_rights?

    transaction_params
  end
  
  def merchant_account_params(params)
    merchant_account_params = {
      :individual => {
        :first_name => params[:first_name],
        :last_name => params[:last_name],
        :email => params[:email],
        :phone => params[:phone],
        :date_of_birth => params[:date_of_birth],
        :ssn => params[:ssn],
        :address => {
          :street_address => params[:street_address],
          :postal_code => params[:postal_code],
          :locality => params[:locality],
          :region => params[:region]
        }
      },
      :business => {
        :legal_name => params[:business_name],
        :tax_id => params[:tax_id],
        :address => {
          :street_address => params[:business_address],
          :locality => params[:business_locality],
          :region => params[:business_region],
          :postal_code => params[:business_postal_code]
        }
      },
      :funding => {
        :destination => Braintree::MerchantAccount::FundingDestination::Bank,
        # :email => "funding@blueladders.com",
        # :mobile_phone => "5555555555",
        :account_number => params[:account_number],
        :routing_number => params[:routing_number]
      },
      :tos_accepted => params[:tos_accepted],
      :master_merchant_account_id => Person::MASTER_SUB_MERCHANT_ID
    }

    merchant_account_params
  end
end
