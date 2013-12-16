class RenameCommissionPercentageToCommissionFromSeller < ActiveRecord::Migration
  def up
    rename_column :communities, :commission_percentage, :commission_from_seller
  end

  def down
    rename_column :communities, :commission_from_seller, :commission_percentage
  end
end
