class RemoveActiveFromPeople < ActiveRecord::Migration
  def change
    remove_column :people, :active, :boolean, after: :test_group_number, default: true
  end
end
