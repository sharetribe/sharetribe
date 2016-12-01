class Payments::PaypalController < ApplicationController
  protect_from_forgery except: [:webhook]

  before_filter except: [:webhook, :confirm] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end

  def new
    if @current_user.is_seller?
      flash[:error] = "The page you are trying to access is not available."
      redirect_to "/" and return
    end
  end

  def update
    @current_user.update_attribute(:paypal_business_email, params[:business_email])
    redirect_to new_listing_path
  end

  def checkout
    @listing = Listing.find(params[:listing_id])
    if !@listing.author.is_seller?
      flash[:error] = "Can't do payment with paypal at the moment. Contact tech support"
      redirect_to listing_path(@listing) and return
    end

    cost = (@listing.price_cents/100)

    flash[:notice] = "Thank you for purchasing."
    values = {
            business: @listing.author.paypal_business_email,
            cmd: "_xclick",
            upload: 1,
            return: "#{Rails.application.secrets.app_host}#{payments_confirm_checkout_path}",
            # invoice: @listing.id,
            amount: cost,
            item_name: @listing.title,
            item_number: @listing.id,
            quantity: '1',
            notify_url: "#{Rails.application.secrets.app_host}/en/payments/webhook",
            custom: @current_user.id
        }
    redirect_to "#{Rails.application.secrets.paypal_host}/cgi-bin/webscr?" + values.to_query
  end

  def confirm
    redirect_to "/"
  end

  def webhook
    params.permit! # Permit all Paypal input params
    status = params[:payment_status]
    if status == "Completed"
      if params[:custom].present?
        person = Person.find(params[:custom])
        MailCarrier.deliver_now(BraintreeMailer.notify_successfull_purchase(person))
      end
      # @checkout.update_attributes notification_params: params, status: status, transaction_id: params[:txn_id], purchased_at: Time.now
    end
    render nothing: true
  end
end
