class RenameDropdownValueToDropdownFieldValue < ActiveRecord::Migration
  def up
    # Update all doesn't play nicely with default scope
    # http://apidock.com/rails/ActiveRecord/Base/update_all/class#1056-update-all-and-delete-all-don-t-play-nicely-with-default-scope
    CustomFieldValue.send(:with_exclusive_scope) { CustomFieldValue.update_all("type = 'DropdownFieldValue'", "type = 'DropdownValue'") }
  end

  def down
    CustomFieldValue.send(:with_exclusive_scope) { CustomFieldValue.update_all("type = 'DropdownValue'", "type = 'DropdownFieldValue'") }
  end
end
