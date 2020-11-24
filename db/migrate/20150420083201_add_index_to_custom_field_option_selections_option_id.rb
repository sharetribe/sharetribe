class AddIndexToCustomFieldOptionSelectionsOptionId < ActiveRecord::Migration
  def change
    add_index :custom_field_option_selections, :custom_field_option_id
  end
end
