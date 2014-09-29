class MoveListingConversationToTransactions < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO transactions (id, starter_id, listing_id, conversation_id, automatic_confirmation_after_days, community_id, created_at, updated_at)
      (SELECT
        conversations.id,
        participations.person_id,
        conversations.listing_id,
        conversations.id,
        conversations.automatic_confirmation_after_days,
        conversations.community_id,
        conversations.created_at,
        conversations.updated_at
        FROM conversations
        INNER JOIN participations ON (conversations.id = participations.conversation_id AND participations.is_starter = 1)
        WHERE (conversations.type = 'ListingConversation')
      )
    ")
  end

  def down
    execute("
      UPDATE conversations
      INNER JOIN transactions ON (conversations.id = transactions.conversation_id)
      SET conversations.listing_id = transactions.listing_id,
          conversations.automatic_confirmation_after_days = transactions.automatic_confirmation_after_days,
          conversations.community_id = transactions.community_id,
          conversations.type = 'ListingConversation'
    ")

    execute("UPDATE conversations SET type ='Conversation' WHERE listing_id IS NULL")

    execute("DELETE FROM transactions")
  end
end
