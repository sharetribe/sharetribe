class AddNameDisplayTypeToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :name_display_type, :string, :default => "first_name_with_initial"
  end
end
