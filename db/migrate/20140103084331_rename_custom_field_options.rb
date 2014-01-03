class RenameCustomFieldOptions < ActiveRecord::Migration
  def up
  	rename_column :selected_options, :custom_field_options_id, :custom_field_option_id
  end

  def down
  	rename_column :selected_options, :custom_field_option_id, :custom_field_options_id
  end
end
