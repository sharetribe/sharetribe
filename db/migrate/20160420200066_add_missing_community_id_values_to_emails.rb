class AddMissingCommunityIdValuesToEmails < ActiveRecord::Migration

  # The migration that duplicates emails is already adding
  # community_id to those newly created rows. This
  # migration only adds community_id to those rows that
  # were not cloned.

  def up
    execute("
      UPDATE emails AS e, people AS p
      SET e.community_id = p.community_id
      WHERE e.person_id = p.id
        AND p.cloned_from IS NULL
    ")
  end
  def down
    execute("
      UPDATE emails AS e, people AS p
      SET e.community_id = NULL
      WHERE e.person_id = p.id
        AND p.cloned_from IS NULL
   ")
  end
end
