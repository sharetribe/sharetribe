class AddCommissionPercentageToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :commission_percentage, :integer
  end
end
