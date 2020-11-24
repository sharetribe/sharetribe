class RemovePaymentRows < ActiveRecord::Migration

  def up
    drop_table "payment_rows"
  end

  def down
    create_table "payment_rows", force: :cascade do |t|
      t.integer  "payment_id", limit: 4
      t.integer  "vat",        limit: 4
      t.integer  "sum_cents",  limit: 4
      t.string   "currency",   limit: 255
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
      t.string   "title",      limit: 255
    end

    add_index "payment_rows", ["payment_id"], name: "index_payment_rows_on_payment_id", using: :btree
  end
end
