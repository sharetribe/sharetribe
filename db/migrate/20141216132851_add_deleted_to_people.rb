class AddDeletedToPeople < ActiveRecord::Migration[5.2]
def change
    add_column :people, :deleted, :boolean, default: false
  end
end
