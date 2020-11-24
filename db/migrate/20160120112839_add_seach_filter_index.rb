class AddSeachFilterIndex < ActiveRecord::Migration
  def change
    add_index :custom_fields, :search_filter
  end
end
