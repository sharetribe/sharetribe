class OrderPermissionScopeCanBeNull < ActiveRecord::Migration[5.2]
  def up
    change_column_null :order_permissions, :scope, true
  end

  def down
    change_column_null :order_permissions, :scope, false
  end
end
