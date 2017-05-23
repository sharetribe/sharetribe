class AcceptFreeConversationsController < ApplicationController

  before_action do |controller|
    controller.ensure_logged_in t("layouts.notifications.you_must_log_in_to_accept_or_reject")
  end

  before_action :fetch_conversation
  before_action :fetch_listing

  before_action :ensure_is_author
  before_action :fetch_transaction

  def accept
    res = accept_free_transaction(@current_community.id, @tx_id)
    flash[:notice] = t("conversations.conversation.accepted_offer") if res[:status] == 'free_accepted'
    redirect_to person_transaction_path(person_id: @current_user.id, id: @tx_id)
  end

  def reject
    res = reject_free_transaction(@current_community.id, @tx_id)
    flash[:notice] =t("conversations.conversation.rejected_offer") if res[:status] == 'free_rejected'
    redirect_to person_transaction_path(person_id: @current_user.id, id: @tx_id)
  end

  private

    def fetch_conversation
      @listing_conversation = @current_community.transactions.find(params[:id])
    end

    def fetch_listing
      @listing = @listing_conversation.listing
    end

    def ensure_is_author
      unless @listing.author == @current_user
        flash[:error] = "Only listing author can perform the requested action"
        redirect_to (session[:return_to_content] || root)
      end
    end

    def fetch_transaction
      @tx_id = params[:id]
      @tx = TransactionService::API::Api.transactions.query(@tx_id)

      if @tx[:current_state] != :free
        redirect_to person_transaction_path(person_id: @current_user.id, id: @tx_id)
        return
      end
    end

    def accept_free_transaction(community_id, tx_id)
      TransactionService::Transaction.accept_free(community_id: community_id,
                                                    transaction_id: tx_id,
                                                  )
    end

    def reject_free_transaction(community_id, tx_id)
      TransactionService::Transaction.reject_free(community_id: community_id,
                                                    transaction_id: tx_id,
                                                  )
    end

end
