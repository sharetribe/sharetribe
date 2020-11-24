class AddVatInUseToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :vat, :integer
  end
end
