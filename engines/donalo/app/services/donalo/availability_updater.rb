module Donalo
  class AvailabilityUpdater < StockUpdater
    def update
      return unless should_be_updated?

      listing.open = false
      listing.save
    end

    private

    def should_be_updated?
      listing && stock && current_quantity <= 0
    end

    attr_reader :transaction_id
  end
end

