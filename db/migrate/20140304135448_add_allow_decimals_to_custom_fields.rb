class AddAllowDecimalsToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :allow_decimals, :boolean, :default => false
  end
end
