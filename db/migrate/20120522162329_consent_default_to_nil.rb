class ConsentDefaultToNil < ActiveRecord::Migration[5.2]
def self.up
    change_column_default(:community_memberships, :consent, nil)
    change_column_default(:communities, :consent, nil)
  end

  def self.down
    change_column_default(:community_memberships, :consent, "KASSI_CO1.0")
    change_column_default(:communities, :consent, "KASSI_CO1.0")
  end
end
