module Admin
  class TransactionsService
    PER_PAGE = 30

    attr_reader :community, :params, :format, :current_user, :personal, :per_page

    def initialize(community, params, format, current_user, personal = false, per_page = PER_PAGE)
      @community = community
      @params = params
      @format = format
      @current_user = current_user
      @personal = personal
      @per_page = per_page
    end

    def transactions
      @transactions ||= transactions_scope
        .paginate(page: params[:page], per_page: params[:per_page] || per_page)
    end

    def transaction
      @transaction ||= transactions_scope.find(params[:id])
    end

    def count
      @count ||= transactions_scope.count
    end

    def transactions_scope
      scope = Transaction.exist.initialized.by_community(community.id)

      if personal
        scope = scope.for_person(current_user)
      end

      if params[:q].present?
        pattern = "%#{params[:q]}%"
        scope = scope.search_by_party_or_listing_title(pattern)
      end
      if params[:status].present? && params[:status].is_a?(String) || params[:status]&.reject(&:empty?).present?
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
        metadata: metadata
      )
      result.success
    end

    def cancel
      return false unless can_transition_to?(:canceled)

      result = TransactionService::Transaction.cancel(
        community_id: community.id, transaction_id: transaction.id,
        message: nil, sender_id: nil,
        metadata: metadata
      )
      result.success
    end

    # Admins have to contact users, discuss with them and decide what to do.
    # Refunds are not done via the marketplace but outside of it.
    # There is no actual refund for now.
    def refund
      transition_to!(:refunded)
    end

    def dismiss
      transition_to!(:dismissed)
    end

    private

    def can_transition_to?(new_status)
      transaction && state_machine.can_transition_to?(new_status)
    end

    def transition_to!(new_state)
      return false unless can_transition_to?(new_state)

      transaction.update_column(:current_state, new_state) #rubocop:disable Rails/SkipsModelValidations
      state_machine.transition_to!(new_state, metadata)
    end

    def state_machine
      @state_machine ||= TransactionProcessStateMachine.new(transaction, transition_class: TransactionTransition)
    end

    def metadata
      { user_id: current_user.id, executed_by_admin: true }
    end
  end
end
