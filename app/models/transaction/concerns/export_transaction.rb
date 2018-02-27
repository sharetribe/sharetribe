module ExportTransaction
  extend ActiveSupport::Concern

  def last_activity
    [last_transition_at, conversation&.last_message_at].compact.max
  end

  included do
    class << self
      def for_community_sorted_by_column(community_id, sort_column, sort_direction, limit, offset)
        sort_column = "transactions.#{sort_column}" if sort_column.index('.').nil?
        exist.by_community(community_id)
          .with_payment_conversation
          .includes(:listing)
          .limit(limit)
          .offset(offset)
          .order("#{sort_column} #{sort_direction}")
      end

      def for_community_sorted_by_activity(community_id, sort_direction, limit, offset, eager_includes = false)
        tx_scope = exist.by_community(community_id)
          .with_payment_conversation_latest(sort_direction)
          .limit(limit)
          .offset(offset)
        tx_scope = tx_scope.for_csv_export if eager_includes
        tx_scope
      end
    end
  end
end
