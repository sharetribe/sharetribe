class AddMissingCommunityIdValuesToPeople < ActiveRecord::Migration

  # The migration that duplicates people is already adding
  # community_id to those newly created rows. This
  # migration only adds community_id to those rows that
  # were not cloned.

  def up
    execute("
      UPDATE people AS p, community_memberships AS cm
      SET p.community_id = cm.community_id
      WHERE cm.person_id = p.id
        AND p.cloned_from IS NULL
    ")
  end
  def down
    execute("
      UPDATE people
      SET community_id = NULL
      WHERE cloned_from IS NULL
   ")
  end
end
