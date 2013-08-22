class PaymentsController < ApplicationController
  
  include MathHelper
  
  before_filter :payment_can_be_conducted
  
  before_filter :only => [ :new ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end
  
  skip_filter :dashboard_only
  
  def new
    @conversation = Conversation.find(params[:message_id])
    @payment = @conversation.payment  #This expects that each conversation already has a (pending) payment at this point
    
    return_url = done_person_message_payment_url(:id => @payment.id)
    
    @payment_gateway = @current_community.payment_gateways.first
    if @payment_gateway.class == Checkout
      @payment_data = @payment_gateway.payment_data(@payment, 
                  :return_url => return_url,
                  :cancel_url => new_person_message_payment_url,
                  :mock => @current_community.settings["mock_cf_payments"])
      @payment_url = "https://payment.checkout.fi/"
    elsif @payment_gateway.class == Mangopay
      contribution = MangoPay::Contribution.create({
                "UserID" => 497018, 
                "WalletID" => 497022, 
                "Amount" => 123, 
                "ReturnURL" => return_url,
                "PaymentMethodType" => "cb_visa_mastercard", 
                "Culture" => "en"
      })
      
      @payment_url = contribution["PaymentURL"]
    end
    
    
    puts "URLI ON #{@payment_url}"
    #= render :partial => @current_community.payment_gateways.first.form_template
    
  end
  
  def choose_method
    
  end
  
  def done
    @payment = Payment.find(params[:id])
    
    unless @current_community.settings["mock_cf_payments"]
      merchant_key = @payment.recipient_organization.merchant_key
    else
      # Make it possible to demonstrate payment system with mock payments if that's set on in community settings
      merchant_key = "SAIPPUAKAUPPIAS"
    end
    
    calculated_mac = Digest::MD5.hexdigest("#{merchant_key}&#{params["VERSION"]}&#{params["STAMP"]}&#{params["REFERENCE"]}&#{params["PAYMENT"]}&#{params["STATUS"]}&#{params["ALGORITHM"]}").upcase
    
    if calculated_mac == params["MAC"]
    
      if ["2","5","6","7","8","9","10"].include?(params["STATUS"])
        @payment.update_attribute(:status, "paid")
        @payment.conversation.pay
        @payment.conversation.messages.create(:sender_id => @payment.payer.id, :action => "pay")
        Delayed::Job.enqueue(PaymentCreatedJob.new(@payment.id, @current_community.id))
        flash[:notice] = t("layouts.notifications.payment_successful")
      elsif ["3","4"].include?(params["STATUS"])
        flash[:notice] = t("layouts.notifications.payment_waiting_for_later_accomplishment")
      else
        flash[:warning] = t("layouts.notifications.payment_canceled")
      end
      
    else # the security check didn't go through
      flash[:error] = t("layouts.notifications.error_in_payment")
      ApplicationHelper.send_error_notification("Payment security check failed", "Payment Error", params)
      
    end
    redirect_to person_message_path(:id => params[:message_id])
  end
  
  
  private
  
  def payment_can_be_conducted
    @conversation = Conversation.find(params[:message_id])
    redirect_to person_message_path(@current_user, @conversation) unless @conversation.requires_payment?(@current_community)
  end
  
end