class MessagesController < ApplicationController
  
  before_filter :logged_in
  
  def index
    save_navi_state(['own','inbox','',''])
    @received_messages = Message.find(:all, :order => 'id DESC', :conditions => "receiver_id = '" + @current_user.id + "'")
    @sent_messages = Message.find(:all, 
                                  :order => 'id DESC', 
                                  :conditions => "sender_id = '" + @current_user.id + "'",
                                  :select => "id, created_at, sender_id, receiver_id, listing_id", 
                                  :group => 'sender_id, receiver_id, listing_id')
  end
  
  def conversation
    @conversation = Message.find(:all, 
                                 :order => 'id DESC', 
                                 :conditions => "sender_id = '" + params[:s] + 
                                                "' AND receiver_id = '" + params[:r] +
                                                "' AND listing_id = '" + params[:l] + "'")
    #@next_conversation = Message.find(:first, :conditions => ["id > ?", @message.id]) || @message
    #@previous_conversation = Message.find(:last, :conditions => ["id < ?", @message.id]) || @message
    @next_conversation = @conversation
    @previous_conversation = @conversation
  end
  
  def create
    @message = Message.new(params[:message])
    if @message.save
      @conversation = @current_user.conversations(:listing_id => params[:message][:listing_id])
      unless @conversation
        @conversation = Conversation.new(:listing_id => params[:message][:listing_id], :title => params[:message][:title])
        @conversation.save
      end  
      @conversation.messages << @message
      @current_user.conversations << @conversation
      Person.find(params[:message][:receiver_id]).conversations << @conversation
      flash[:notice] = :reply_sent  
      redirect_to listing_path(params[:message][:listing_id])
    else
      flash[:error] = :reply_could_not_be_sent
      render :template => "listings/reply"
    end    
  end
  
end
