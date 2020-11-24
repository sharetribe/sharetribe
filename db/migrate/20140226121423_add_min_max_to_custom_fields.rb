class AddMinMaxToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :min, :float
    add_column :custom_fields, :max, :float
  end
end
