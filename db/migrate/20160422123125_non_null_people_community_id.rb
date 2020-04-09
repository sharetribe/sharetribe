class NonNullPeopleCommunityId < ActiveRecord::Migration[5.2]
def change
    change_column_null :people, :community_id, false
  end
end
