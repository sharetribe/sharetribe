class AddActionToMessages < ActiveRecord::Migration[5.2]
def change
    add_column :messages, :action, :string
  end
end
