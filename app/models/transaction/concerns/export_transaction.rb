module ExportTransaction
  extend ActiveSupport::Concern

  def last_activity
    [last_transition_at, conversation&.last_message_at].compact.max
  end

  included do
    class << self
      def for_community_sorted_by_activity(community_id, sort_direction, eager_includes = false)
        tx_scope = exist.by_community(community_id)
          .with_payment_conversation_latest(sort_direction)
        tx_scope = tx_scope.for_csv_export if eager_includes
        tx_scope
      end
    end
  end
end
