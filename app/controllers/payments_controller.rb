class PaymentsController < ApplicationController
  
  before_filter :payment_can_be_conducted
  
  skip_filter :dashboard_only
  
  def new
    @conversation = Conversation.find(params[:message_id])
    @payment = @conversation.payment  #This expects that each conversation already has a (pending) payment at this point
    
    @payment_data = {
      "VERSION"   => "0001",
      "STAMP"     => "sharetribe_#{@payment.id}",
      "AMOUNT"    => @payment.sum_cents,
      "REFERENCE" => "1009",
      "MESSAGE"   => "testimaksu",
      "LANGUAGE"  => "FI",
      "MERCHANT"  => @payment.recipient_organization.merchant_id,
      "RETURN"    => done_person_message_payment_url(:id => @payment.id),
      "CANCEL"    => new_person_message_payment_url,
      "COUNTRY"   => "FIN",
      "CURRENCY"  => "EUR",
      "DEVICE"    => 1,
      "CONTENT"   => 1,
      "TYPE"      => 0,
      "ALGORITHM" => 2,
      "DELIVERY_DATE" => Time.now.strftime("%Y%m%d"),
    }
    @payment_data["STAMP"] = Devise.friendly_token if Rails.env.test?
    @payment_data["MAC"] = Digest::MD5.hexdigest("#{@payment_data['VERSION']}+#{@payment_data['STAMP']}+#{@payment_data['AMOUNT']}+#{@payment_data['REFERENCE']}+#{@payment_data['MESSAGE']}+#{@payment_data['LANGUAGE']}+#{@payment_data['MERCHANT']}+#{@payment_data['RETURN']}+#{@payment_data['CANCEL']}+#{@payment_data['REJECT']}+#{@payment_data['DELAYED']}+#{@payment_data['COUNTRY']}+#{@payment_data['CURRENCY']}+#{@payment_data['DEVICE']}+#{@payment_data['CONTENT']}+#{@payment_data['TYPE']}+#{@payment_data['ALGORITHM']}+#{@payment_data['DELIVERY_DATE']}+#{@payment_data['FIRSTNAME']}+#{@payment_data['FAMILYNAME']}+#{@payment_data['ADDRESS']}+#{@payment_data['POSTCODE']}+#{@payment_data['POSTOFFICE']}+#{@payment.recipient_organization.merchant_key}").upcase
    
  end
  
  def choose_method
    
  end
  
  def done
    @payment = Payment.find(params[:id])
    @payment.update_attribute(:status, "paid")
    @payment.conversation.pay
    Delayed::Job.enqueue(PaymentCreatedJob.new(@payment.id, @current_community.id))
    flash[:notice] = t("layouts.notifications.payment_successful")
    redirect_to person_message_path(:id => params[:message_id])
  end
  
  
  private
  
  def payment_can_be_conducted
    @conversation = Conversation.find(params[:message_id])
    redirect_to person_message_path(@current_user, @conversation) unless @conversation.requires_payment?(@current_community)
  end
  
end