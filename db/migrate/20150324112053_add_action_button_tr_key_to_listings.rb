class AddActionButtonTrKeyToListings < ActiveRecord::Migration
  def change
    add_column :listings, :action_button_tr_key, :string, after: :shape_name_tr_key
  end
end
