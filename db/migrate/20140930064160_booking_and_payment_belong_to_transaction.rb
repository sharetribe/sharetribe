class BookingAndPaymentBelongToTransaction < ActiveRecord::Migration
  def up
    rename_column :bookings, :listing_conversation_id, :transaction_id
    rename_column :payments, :conversation_id, :transaction_id
  end

  def down
    execute("UPDATE bookings
      INNER JOIN transactions ON (bookings.transaction_id = transactions.id)
      SET transaction_id = transactions.conversation_id")

    execute("UPDATE payments
      INNER JOIN transactions ON (payments.transaction_id = transactions.id)
      SET transaction_id = transactions.conversation_id")

    rename_column :bookings, :transaction_id, :listing_conversation_id
    rename_column :payments, :transaction_id, :conversation_id
  end
end
