class AddCommunityIdValuesToPeople < ActiveRecord::Migration
  def up
    execute("
      UPDATE people AS p, community_memberships AS cm
      SET p.community_id = cm.community_id
      WHERE cm.person_id = p.id
    ")
  end
  def down
    # Do nothing.
    # Some of the rows in the people table already contained
    # the community_id and we don't want to clear those
  end
end
