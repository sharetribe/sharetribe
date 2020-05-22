module Donalo
  class StockUpdater
    def initialize(transaction_id:, rollback: false)
      @transaction_id = transaction_id
      @rollback = rollback
    end

    def update
      return unless stock

      stock.amount = new_amount
      stock.save
    end

    private

    attr_reader :transaction_id, :rollback

    def new_amount
      delta = -transaction.listing_quantity
      delta = -delta if rollback

      stock.amount + delta
    end

    def transaction
      @transaction ||= Transaction.find(transaction_id)
    end

    def listing
      @listing ||= transaction&.listing
    end

    def stock
      @stock ||= begin
        if listing
          Stock.find_by(listing: listing)
        else
          nil
        end
      end
    end
  end
end
