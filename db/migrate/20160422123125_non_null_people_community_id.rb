class NonNullPeopleCommunityId < ActiveRecord::Migration
  def change
    change_column_null :people, :community_id, false
  end
end
