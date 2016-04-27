class NotNullUsername < ActiveRecord::Migration
  def change
    change_column_null :people, :username, false
  end
end
