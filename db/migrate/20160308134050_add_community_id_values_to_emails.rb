class AddCommunityIdValuesToEmails < ActiveRecord::Migration
  def up
    execute("
      UPDATE emails AS e, community_memberships AS cm
      SET e.community_id = cm.community_id
      WHERE cm.person_id = e.person_id
    ")
  end
  def down
    execute("
      UPDATE emails
      SET community_id = NULL
   ")
  end
end
