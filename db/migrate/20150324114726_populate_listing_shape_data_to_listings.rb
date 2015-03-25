class PopulateListingShapeDataToListings < ActiveRecord::Migration
  def up
    execute("
      UPDATE listings
      LEFT JOIN transaction_types ON (listings.transaction_type_id = transaction_types.id)
      SET
        listings.transaction_process_id = transaction_types.transaction_process_id,
        listings.shape_name_tr_key = transaction_types.name_tr_key,
        listings.action_button_tr_key = transaction_types.action_button_tr_key
    ")
  end

  def down
    execute("
      UPDATE listings
      SET
        listings.transaction_process_id = NULL,
        listings.shape_name_tr_key = NULL,
        listings.action_button_tr_key = NULL
    ")
  end
end
