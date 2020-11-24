class AddRequiredToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :required, :boolean, :default => true
  end
end
