class AddLastTransitionAtToTransaction < ActiveRecord::Migration[5.2]
def up
    add_column(:transactions, :last_transition_at, :datetime)
  end

  def down
    remove_column(:transactions, :last_transition_at)
  end
end
