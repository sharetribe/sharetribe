class PopulateTransactionListingFields < ActiveRecord::Migration
  def up
    execute("
UPDATE transactions t
LEFT JOIN listings l on t.listing_id = l.id
SET t.listing_title = l.title, t.listing_author_id = l.author_id, t.unit_price_cents = l.price_cents, t.unit_price_currency = l.currency;
")
  end

  def down
    # no-op
  end
end
