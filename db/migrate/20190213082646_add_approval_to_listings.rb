class AddApprovalToListings < ActiveRecord::Migration[5.1]
  def change
    add_column :listings, :approval, :integer, default: 0
  end
end
