class Payments::PaypalController < ApplicationController
  protect_from_forgery except: [:webhook]

  def new
  end

  def update
    @current_user.update_attribute(:paypal_business_email, params[:business_email])
    redirect_to new_listing_path
  end

  def checkout
    @listing = Listing.find(params[:listing_id])
    if !@current_user.is_seller?
      flash[:error] = "There is something wrong. Contact Tech Support"
      redirect_to listing_path(@listing) and return
    end

    cost = (@listing.price_cents/100)

    flash[:notice] = "Thank you for purchasing."
    values = {
            business: @current_user.paypal_business_email,
            cmd: "_xclick",
            upload: 1,
            return: "#{Rails.application.secrets.app_host}#{payments_confirm_checkout_path}",
            invoice: @listing.id,
            amount: cost,
            item_name: @listing.title,
            item_number: @listing.id,
            quantity: '1',
            notify_url: "#{Rails.application.secrets.app_host}/payments/webhook"
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
      MailCarrier.deliver_now(BraintreeMailer.notify_successfull_purchase(@current_user))
      # @checkout.update_attributes notification_params: params, status: status, transaction_id: params[:txn_id], purchased_at: Time.now
    end
    render nothing: true
  end
end
