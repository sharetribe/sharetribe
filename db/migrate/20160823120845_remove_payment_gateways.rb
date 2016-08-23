class RemovePaymentGateways < ActiveRecord::Migration

  def up
    drop_table "payment_gateways"
  end

  def down
    create_table "payment_gateways", force: :cascade do |t|
      t.integer  "community_id",                         limit: 4
      t.string   "type",                                 limit: 255
      t.string   "braintree_environment",                limit: 255
      t.string   "braintree_merchant_id",                limit: 255
      t.string   "braintree_master_merchant_id",         limit: 255
      t.string   "braintree_public_key",                 limit: 255
      t.string   "braintree_private_key",                limit: 255
      t.text     "braintree_client_side_encryption_key", limit: 65535
      t.string   "checkout_environment",                 limit: 255
      t.string   "checkout_user_id",                     limit: 255
      t.string   "checkout_password",                    limit: 255
      t.datetime "created_at",                                         null: false
      t.datetime "updated_at",                                         null: false
    end
  end
end
