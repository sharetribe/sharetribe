class AddCommunityIdValuesToPeople < ActiveRecord::Migration
  def up
    execute("
      UPDATE people AS p, community_memberships AS cm 
      SET p.community_id = cm.community_id
      WHERE cm.person_id = p.id
    ") 
    execute("
      UPDATE people AS p, community_memberships AS cm 
      SET p.community_id = cm.community_id
      WHERE cm.person_id = p.cloned_from
    ") 
  end
  def down
    execute("
      UPDATE people
      SET community_id = NULL
   ")
  end
end
