class AddIndexesForCustomFields < ActiveRecord::Migration
  def up
  	add_index :custom_fields, :community_id
  	add_index :custom_field_names, :custom_field_id
  	add_index :custom_field_option_titles, :custom_field_option_id
  end

  def down
  	remove_index :custom_fields, :community_id
  	remove_index :custom_field_names, :custom_field_id
  	remove_index :custom_field_option_titles, :custom_field_option_id
  end
end
