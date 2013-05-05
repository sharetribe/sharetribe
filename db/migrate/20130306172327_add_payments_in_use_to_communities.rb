class AddPaymentsInUseToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :payments_in_use, :boolean, :default => false
  end
end
