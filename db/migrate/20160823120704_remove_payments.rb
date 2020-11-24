class RemovePayments < ActiveRecord::Migration

  def up
    drop_table "payments"
  end

  def down
    create_table "payments", force: :cascade do |t|
      t.string   "payer_id",                 limit: 255
      t.string   "recipient_id",             limit: 255
      t.integer  "transaction_id",           limit: 4
      t.string   "status",                   limit: 255
      t.datetime "created_at",                                                        null: false
      t.datetime "updated_at",                                                        null: false
      t.integer  "community_id",             limit: 4
      t.integer  "payment_gateway_id",       limit: 4
      t.integer  "sum_cents",                limit: 4
      t.string   "currency",                 limit: 255
      t.string   "type",                     limit: 255, default: "BraintreePayment"
      t.string   "braintree_transaction_id", limit: 255
    end

    add_index "payments", ["payer_id"], name: "index_payments_on_payer_id", using: :btree
    add_index "payments", ["transaction_id"], name: "index_payments_on_conversation_id", using: :btree
  end
end
