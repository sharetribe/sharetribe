class MessagesController < ApplicationController
  
  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_send_a_message"
  end
  
  def create
    @message = Message.new(params[:message])
    @message.save ? (flash[:message_notice] = "reply_sent") : (flash[:error] = "reply_cannot_be_empty")
    respond_to do |format|
      format.html { redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => params[:message][:conversation_id]) }
      format.js { render :layout => false }
    end
  end
  
end
