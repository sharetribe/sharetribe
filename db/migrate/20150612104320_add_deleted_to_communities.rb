class AddDeletedToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :deleted, :boolean, after: :favicon_processing
  end
end
