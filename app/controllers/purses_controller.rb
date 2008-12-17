class PursesController < ApplicationController
  
  def create 
    begin
      @transaction = Transaction.create(params[:transaction])
    rescue Exception => e
      puts e.class
      flash[:error] = :transaction_could_not_be_made
    end
    render :action => "show"
  end
  
   def show
     save_navi_state(['own', 'purse'])
     @title = :purse
     # @sent_transactions = Transaction.find_by_sender_id(@current_user, :order => "created_at DESC")  
     # @received_transactions = Transaction.find_by_receiver_id(@current_user, :order => "created_at DESC")
   end
  
end
