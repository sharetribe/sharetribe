class AddMangopayIdToPeople < ActiveRecord::Migration
  def change
    add_column :people, :mangopay_id, :string
  end
end
