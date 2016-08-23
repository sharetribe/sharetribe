class RemoveBraintreeAccounts < ActiveRecord::Migration
  def up
    drop_table "braintree_accounts"
  end

  def down
    create_table "braintree_accounts", force: :cascade do |t|
      t.datetime "created_at",             null: false
      t.datetime "updated_at",             null: false
      t.string   "first_name",             limit: 255
      t.string   "last_name",              limit: 255
      t.string   "person_id",              limit: 255
      t.string   "email",                  limit: 255
      t.string   "phone",                  limit: 255
      t.string   "address_street_address", limit: 255
      t.string   "address_postal_code",    limit: 255
      t.string   "address_locality",       limit: 255
      t.string   "address_region",         limit: 255
      t.date     "date_of_birth"
      t.string   "routing_number",         limit: 255
      t.string   "hidden_account_number",  limit: 255
      t.string   "status",                 limit: 255
      t.integer  "community_id",           limit: 4
    end
  end
end
