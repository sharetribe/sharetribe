module Admin
  class TransactionsService
    PER_PAGE = 30

    attr_reader :community, :params, :format, :current_user

    def initialize(community, params, format, current_user)
      @community = community
      @params = params
      @format = format
      @current_user = current_user
    end

    def transactions
      @transactions ||= transactions_scope
        .paginate(page: params[:page], per_page: params[:per_page] || PER_PAGE)
    end

    def transaction
      @transaction ||= transactions_scope.find(params[:id])
    end

    def count
      @count ||= transactions_scope.count
    end

    def transactions_scope
      scope = Transaction.exist.by_community(community.id)

      if params[:q].present?
        pattern = "%#{params[:q]}%"
        scope = scope.search_by_party_or_listing_title(pattern)
      end
      if params[:status].present?
        scope = scope.where(current_state: params[:status])
      end
      if params[:sort].nil? || params[:sort] == "last_activity"
        scope = scope.with_payment_conversation_latest(sort_direction)
        scope = scope.for_csv_export if format == :csv
      else
        scope = scope.with_payment_conversation
          .includes(:listing)
          .order("#{sort_column} #{sort_direction}")
      end
      scope
    end

    def sort_column
      column = case params[:sort]
               when "listing"
                "listings.title"
               when "started"
                "created_at"
               end
      column = "transactions.#{column}" if column.present? && column.index('.').nil?
      column
    end

    def sort_direction
      if params[:direction] == "asc"
        "asc"
      else
        "desc" #default
      end
    end

    def confirm
      return false unless can_transition_to?(:confirmed)

      result = TransactionService::Transaction.complete(
        community_id: community.id, transaction_id: transaction.id,
        message: nil, sender_id: nil,
        metadata: { user_id: current_user.id, executed_by_admin: true }
      )
      result.success
    end

    def cancel
      return false unless can_transition_to?(:confirmed)

      result = TransactionService::Transaction.cancel(
        community_id: community.id, transaction_id: transaction.id,
        message: nil, sender_id: nil,
        metadata: { user_id: current_user.id, executed_by_admin: true }
      )
      result.success
    end

    private

    def can_transition_to?(new_status)
      if transaction
        state_machine = TransactionProcessStateMachine.new(transaction, transition_class: TransactionTransition)
        state_machine.can_transition_to?(new_status)
      end
    end
  end
end
