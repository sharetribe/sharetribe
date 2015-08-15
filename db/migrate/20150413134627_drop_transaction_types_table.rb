class DropTransactionTypesTable < ActiveRecord::Migration
  def up

    # remove transaction_type_id indexes
    remove_index "listing_shapes", :name => "index_listing_shapes_on_transaction_type_id"
    remove_index "listing_units",  :name => "index_listing_units_on_transaction_type_id"
    remove_index "listings",       :name => "index_listings_on_transaction_type_id"

    # remove transaction_type_id:s
    remove_column :listing_shapes,  :transaction_type_id
    remove_column :listing_units,   :transaction_type_id
    remove_column :listings,        :transaction_type_id

    drop_table :category_transaction_types
    drop_table :transaction_type_translations
    drop_table :transaction_types

  end

  def down
    # This is from schema.rb (the "force = true" flag is removed)
    create_table "category_transaction_types" do |t|
      t.integer  "category_id"
      t.integer  "transaction_type_id"
      t.datetime "created_at",          :null => false
      t.datetime "updated_at",          :null => false
    end

    add_index "category_transaction_types", ["category_id"], :name => "index_category_transaction_types_on_category_id"
    add_index "category_transaction_types", ["transaction_type_id"], :name => "index_category_transaction_types_on_transaction_type_id"

    # This is from schema.rb (the "force = true" flag is removed)
    create_table "transaction_type_translations" do |t|
      t.integer  "transaction_type_id"
      t.string   "locale"
      t.string   "name"
      t.string   "action_button_label"
      t.datetime "created_at",          :null => false
      t.datetime "updated_at",          :null => false
    end

    add_index "transaction_type_translations", ["transaction_type_id", "locale"], :name => "locale_index"
    add_index "transaction_type_translations", ["transaction_type_id"], :name => "index_transaction_type_translations_on_transaction_type_id"

    # This is from schema.rb (the "force = true" flag is removed)
    create_table "transaction_types" do |t|
      t.string   "type"
      t.integer  "community_id"
      t.integer  "transaction_process_id"
      t.integer  "sort_priority"
      t.boolean  "price_field"
      t.boolean  "preauthorize_payment",       :default => false
      t.string   "price_quantity_placeholder"
      t.string   "price_per"
      t.datetime "created_at",                                    :null => false
      t.datetime "updated_at",                                    :null => false
      t.string   "url"
      t.boolean  "shipping_enabled",           :default => false
      t.string   "name_tr_key"
      t.string   "action_button_tr_key"
    end

    add_index "transaction_types", ["community_id"], :name => "index_transaction_types_on_community_id"
    add_index "transaction_types", ["url"], :name => "index_transaction_types_on_url"


    # add transaction_type_id:s
    add_column :listing_shapes, :transaction_type_id, :integer
    add_column :listing_units,  :transaction_type_id, :integer
    add_column :listings,       :transaction_type_id, :integer

    # add transaction_type_id indexes
    add_index "listing_shapes", ["transaction_type_id"], :name => "index_listing_shapes_on_transaction_type_id"
    add_index "listing_units",  ["transaction_type_id"], :name => "index_listing_units_on_transaction_type_id"
    add_index "listings",       ["transaction_type_id"], :name => "index_listings_on_transaction_type_id"

  end
end
