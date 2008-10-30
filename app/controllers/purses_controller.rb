class PursesController < ApplicationController
  def create 
    @sender = Person.find(params[:transaction][:sender_id])
    @receiver = Person.find(params[:transaction][:receiver_id])
    if(@sender.coin_amount - params[:transaction][:amount] >= PURSE_LIMIT)
      Transaction.transaction do
        @sender.coin_amount = @sender.coin_amount - params[:transaction][:amount]
        @receiver.coin_amount = @receiver.coin_amount + params[:transaction][:amount]
        @transaction = Transaction.new(params[:transaction])
        @sender.save
        @receiver.save
        @transaction.save
        flash[:notice]
        render :action => "show"
      end
    else
     flash[:notice] = :transaction_amount_too_big
     render :action => "show"
    end

  end
  
  def show
    save_navi_state(['own', 'purse'])
    @title = :purse
    @sent_transactions = Transaction.find_by_sender_id(@current_user, :order => "created_at DESC")  
    @received_transactions = Transaction.find_by_receiver_id(@current_user, :order => "created_at DESC")
  end
  
end
