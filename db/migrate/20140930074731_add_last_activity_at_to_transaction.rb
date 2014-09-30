class AddLastActivityAtToTransaction < ActiveRecord::Migration
  def up
    add_column(:transactions, :last_activity_at, :datetime)
  end

  def down
    remove_column(:transactions, :last_activity_at)
  end
end
