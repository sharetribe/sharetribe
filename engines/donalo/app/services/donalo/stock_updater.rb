module Donalo
  class StockUpdater
    def initialize(transaction_id:, rollback: false)
      @transaction_id = transaction_id
      @rollback = rollback
    end

    def update
      return unless stock

      stock.numeric_value = new_amount
      stock.save
    end

    private

    attr_reader :transaction_id, :rollback

    def new_amount
      delta = -transaction.listing_quantity
      delta = -delta if rollback

      stock.numeric_value.to_i + delta
    end

    def transaction
      @transaction ||= Transaction.find(transaction_id)
    end

    def listing
      @listing ||= transaction&.listing
    end

    def stock
      @stock ||= listing.stock
    end
  end
end
