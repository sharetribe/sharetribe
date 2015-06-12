class AddDeletedToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :deleted, :boolean, after: :favicon_processing
  end
end
