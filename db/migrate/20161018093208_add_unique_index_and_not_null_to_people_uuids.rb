class AddUniqueIndexAndNotNullToPeopleUuids < ActiveRecord::Migration[5.2]
def change
    change_column_null :people, :uuid, false
    add_index :people, :uuid, unique: true
  end
end
