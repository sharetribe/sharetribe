class AddCommissionFromSellerToTransaction < ActiveRecord::Migration
  def change
    add_column :transactions, :commission_from_seller, :integer, after: :current_state
  end
end
