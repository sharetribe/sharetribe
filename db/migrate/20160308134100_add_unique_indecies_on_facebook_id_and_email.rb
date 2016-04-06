class AddUniqueIndeciesOnFacebookIdAndEmail < ActiveRecord::Migration
  def change
    remove_index :people, column: :facebook_id
    add_index :people, [:facebook_id, :community_id], unique: true

    # Don't remove existing index on 'address'. We still do searches
    # with the address only
    add_index :emails, [:address, :community_id], unique: true
  end
end
