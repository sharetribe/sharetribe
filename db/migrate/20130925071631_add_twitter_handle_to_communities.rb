class AddTwitterHandleToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :twitter_handle, :string
  end
end
