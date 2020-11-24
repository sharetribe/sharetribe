class RenameDropdownToDropdownField < ActiveRecord::Migration
  def up
    CustomField.update_all("type = 'DropdownField'", "type = 'Dropdown'")
  end

  def down
    CustomField.update_all("type = 'Dropdown'", "type = 'DropdownField'")
  end
end
