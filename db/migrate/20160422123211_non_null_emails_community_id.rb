class NonNullEmailsCommunityId < ActiveRecord::Migration
  def change
    change_column_null :emails, :community_id, false
  end
end
