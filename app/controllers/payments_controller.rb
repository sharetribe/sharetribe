class PaymentsController < ApplicationController
  
  before_filter :payment_can_be_conducted
  
  skip_filter :dashboard_only
  
  def new
    
  end
  
  def choose_method
    
  end
  
  private
  
  def payment_can_be_conducted
    @conversation = Conversation.find(params[:message_id])
    redirect_to person_message_path(@current_user, @conversation) unless @conversation.requires_payment?(@current_community)
  end
  
end