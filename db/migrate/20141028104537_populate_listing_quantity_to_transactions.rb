class PopulateListingQuantityToTransactions < ActiveRecord::Migration[5.2]
def up
    # Transactions with booking
    execute("UPDATE transactions, bookings SET transactions.listing_quantity = (DATEDIFF(bookings.end_on, bookings.start_on) + 1) WHERE transactions.id = bookings.transaction_id")
  end

  def down
    execute("UPDATE transactions SET listing_quantity = 1")
  end
end
