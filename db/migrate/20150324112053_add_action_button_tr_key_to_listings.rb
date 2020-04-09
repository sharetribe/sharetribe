class AddActionButtonTrKeyToListings < ActiveRecord::Migration[5.2]
def change
    add_column :listings, :action_button_tr_key, :string, after: :shape_name_tr_key
  end
end
