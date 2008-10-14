class TransactionsController < ApplicationController
  
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
        #redirect_to purse
      end
    else
     flash[:notice] = :transaction_amount_too_big
     render :action => "new"
    end

  end

end
