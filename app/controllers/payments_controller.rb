class PaymentsController < ApplicationController
  
  include MathHelper
  
  before_filter :payment_can_be_conducted
  
  before_filter :only => [ :new, :done ] do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_view_your_inbox")
  end
  
  skip_filter :dashboard_only
  
  def new
    @conversation = Conversation.find(params[:message_id])
    @payment = @conversation.payment  #This expects that each conversation already has a (pending) payment at this point
    
    unless @current_community.settings["mock_cf_payments"]
      merchant_id = @payment.recipient_organization.merchant_id
      merchant_key = @payment.recipient_organization.merchant_key
    else
      # Make it possible to demonstrate payment system with mock payments if that's set on in community settings
      merchant_id = "375917"
      merchant_key = "SAIPPUAKAUPPIAS"
    end
    
    
    @payment_data = {
      "VERSION"   => "0001",
      "STAMP"     => "sharetribe_#{@payment.id}",
      "AMOUNT"    => @payment.total_sum.cents,
      "REFERENCE" => "1009",
      "MESSAGE"   => @payment.summary_string,
      "LANGUAGE"  => "FI",
      "MERCHANT"  => merchant_id,
      "RETURN"    => done_person_message_payment_url(:id => @payment.id),
      "CANCEL"    => new_person_message_payment_url,
      "COUNTRY"   => "FIN",
      "CURRENCY"  => "EUR",
      "DEVICE"    => 1,
      "CONTENT"   => 1,
      "TYPE"      => 0,
      "ALGORITHM" => 2,
      "DELIVERY_DATE" => 2.weeks.from_now.strftime("%Y%m%d")
    }
    @payment_data["STAMP"] = Devise.friendly_token if Rails.env.test?
    @payment_data["MAC"] = Digest::MD5.hexdigest("#{@payment_data['VERSION']}+#{@payment_data['STAMP']}+#{@payment_data['AMOUNT']}+#{@payment_data['REFERENCE']}+#{@payment_data['MESSAGE']}+#{@payment_data['LANGUAGE']}+#{@payment_data['MERCHANT']}+#{@payment_data['RETURN']}+#{@payment_data['CANCEL']}+#{@payment_data['REJECT']}+#{@payment_data['DELAYED']}+#{@payment_data['COUNTRY']}+#{@payment_data['CURRENCY']}+#{@payment_data['DEVICE']}+#{@payment_data['CONTENT']}+#{@payment_data['TYPE']}+#{@payment_data['ALGORITHM']}+#{@payment_data['DELIVERY_DATE']}+#{@payment_data['FIRSTNAME']}+#{@payment_data['FAMILYNAME']}+#{@payment_data['ADDRESS']}+#{@payment_data['POSTCODE']}+#{@payment_data['POSTOFFICE']}+#{merchant_key}").upcase
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