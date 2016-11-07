class CopyCommunityCurrencyToTheCurrencyColumn < ActiveRecord::Migration
  def up
    sql = "UPDATE communities c
           SET c.currency = c.available_currencies"
    exec_update(sql, "Copy currency from available_currencies to currency", [])
  end

  def down
    sql = "UPDATE communities c
           SET c.available_currencies = c.currency"
    exec_update(sql, "Copy currency from currency to available_currencies", [])
  end
end
