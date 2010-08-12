class MessagesController < ApplicationController
  
  before_filter :only => [ :new, :create ] do |controller|
    controller.ensure_logged_in "you_must_log_in_to_send_a_message"
  end
  
  def create
    @message = Message.create!(params[:message])
    flash[:notice] = "Thanks for commenting!" unless @message.new_record?
    respond_to do |format|
      format.html { redirect_to single_conversation_path(:conversation_type => "received", :person_id => @current_user.id, :id => params[:message][:conversation_id]) }
      format.js {render :layout => false}
    end
  end
  
end
