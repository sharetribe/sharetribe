class RenameSelectedOptionsToCustomFieldOptionSelections < ActiveRecord::Migration
  def up
  	rename_table :selected_options, :custom_field_option_selections
  end

  def down
  	rename_table :custom_field_option_selections, :selected_options 
  end
end
