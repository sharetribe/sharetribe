class DeleteNullValuesFromCommunityMemberships < ActiveRecord::Migration
  def up
    execute("DELETE FROM community_memberships WHERE person_id IS NULL OR community_id IS NULL")
  end

  def down
    # Nothing. The UP migration deletes data, so we don't have anyway to get that data back
  end
end
