class RemovePeopleEmail < ActiveRecord::Migration
  def up
    remove_column :people, :email
  end

  def down
    add_column :people, :email, :string, after: :username
  end
end
