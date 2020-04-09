class AddConsentToCommunities < ActiveRecord::Migration[5.2]
def self.up
    add_column :communities, :consent, :string, :default => "KASSI_FI1.0"
  end

  def self.down
    remove_column :communities, :consent
  end
end
