class CopyCommunityIdFromPeopleToEmails < ActiveRecord::Migration
  def up
    exec_update(
      ["UPDATE emails e",
       "LEFT JOIN people p ON p.id = e.person_id",
       "SET e.community_id = -1",
       "WHERE p.community_id = -1"].join(" "),
      "Set community_id -1",
      []
    )
  end

  def down
    exec_update(
      ["UPDATE emails e",
       "LEFT JOIN people p ON p.id = e.person_id",
       "SET e.community_id = NULL",
       "WHERE p.community_id = -1"].join(" "),
      "Set community_id NULL",
      []
    )
  end
end
