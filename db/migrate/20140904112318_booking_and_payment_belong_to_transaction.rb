class BookingAndPaymentBelongToTransaction < ActiveRecord::Migration
  def change
    rename_column :bookings, :listing_conversation_id, :transaction_id
    rename_column :payments, :conversation_id, :transaction_id
    rename_index :payments, :conversation_id, :transaction_id
  end
end
