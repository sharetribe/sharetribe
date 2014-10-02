class AddCurrentStateToTransaction < ActiveRecord::Migration
  def change
    add_column(:transactions, :current_state, :string)
  end
end
