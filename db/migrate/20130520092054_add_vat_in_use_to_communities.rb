class AddVatInUseToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :vat, :integer
  end
end
