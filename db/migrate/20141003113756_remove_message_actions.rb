class RemoveMessageActions < ActiveRecord::Migration[5.2]
def change
    remove_column :messages, :action
  end
end
