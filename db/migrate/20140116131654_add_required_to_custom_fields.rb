class AddRequiredToCustomFields < ActiveRecord::Migration[5.2]
  def change
    add_column :custom_fields, :required, :boolean, :default => true
  end
end
