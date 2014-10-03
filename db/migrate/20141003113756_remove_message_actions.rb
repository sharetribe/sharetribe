class RemoveMessageActions < ActiveRecord::Migration
  def change
    remove_column :messages, :action
  end
end
