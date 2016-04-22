class NotNullEmailAddress < ActiveRecord::Migration
  def change
    change_column_null :emails, :address, false
  end
end
