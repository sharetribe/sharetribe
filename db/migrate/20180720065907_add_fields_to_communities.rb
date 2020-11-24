class AddFieldsToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :footer_theme, :integer, default: 0
    add_column :communities, :footer_copyright, :text
  end
end
