class RenameCommissionPercentageToCommissionFromSeller < ActiveRecord::Migration[5.2]
def up
    rename_column :communities, :commission_percentage, :commission_from_seller
  end

  def down
    rename_column :communities, :commission_from_seller, :commission_percentage
  end
end
