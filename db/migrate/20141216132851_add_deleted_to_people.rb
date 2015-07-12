class AddDeletedToPeople < ActiveRecord::Migration
  def change
    add_column :people, :deleted, :boolean, default: false
  end
end
