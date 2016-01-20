class AddShowFilterToCustomFields < ActiveRecord::Migration
  def change
    add_column :custom_fields, :search_filter, :boolean, after: :sort_priority, default: false, null: false
  end
end

