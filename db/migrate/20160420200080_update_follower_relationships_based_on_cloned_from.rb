class UpdateFollowerRelationshipsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    add_column :follower_relationships, :needs_to_be_deleted, :boolean, default: true
    ActiveRecord::Base.transaction do
      execute("
        INSERT INTO follower_relationships
          (person_id, follower_id, created_at, updated_at, needs_to_be_deleted)
          (SELECT person.id, follower.id, fr.created_at, fr.updated_at, #{false}
            FROM follower_relationships AS fr
            LEFT JOIN people as person
            ON person.id = fr.person_id OR person.cloned_from = fr.person_id
            LEFT JOIN people as follower
            ON follower.id = fr.follower_id OR follower.cloned_from = fr.follower_id
            WHERE person.community_id = follower.community_id)
          ON DUPLICATE KEY UPDATE needs_to_be_deleted = false
      ")
      execute("
        DELETE FROM follower_relationships
        WHERE needs_to_be_deleted = true
      ")
    end
    remove_column :follower_relationships, :needs_to_be_deleted
  end

  def down
    ActiveRecord::Base.transaction do

      # New relationships created in the migration are converted
      # into old ones by replacing the cloned person IDs with
      # original ones. Cloned person IDs in relationships are
      # discovered in 3 steps:
      #
      # 1. relationships where both person_id and follower_id are from cloned users
      # 2. relationships where person_id is from an original user and follower_id is from a cloned one
      # 3. relationships where person_id is from a cloned user and follower_id is from an original one
      #
      # Once the old relationships are restored relationships with
      # cloned people can be removed.

      execute("
        INSERT IGNORE INTO follower_relationships
          (person_id, follower_id, created_at, updated_at)
          SELECT person.cloned_from, follower.cloned_from, fr.created_at, fr.updated_at
            FROM follower_relationships AS fr
            LEFT JOIN people AS person ON fr.person_id = person.id
            LEFT JOIN people AS follower ON fr.follower_id = follower.id
            WHERE
              person.cloned_from IS NOT NULL AND
              follower.cloned_from IS NOT NULL
          UNION ALL
          SELECT person.id, follower.cloned_from, fr.created_at, fr.updated_at
            FROM follower_relationships AS fr
            LEFT JOIN people AS person ON fr.person_id = person.id
            LEFT JOIN people AS follower ON fr.follower_id = follower.id
            WHERE
              person.cloned_from IS NULL AND
              follower.cloned_from IS NOT NULL
          UNION ALL
            SELECT person.cloned_from, follower.id, fr.created_at, fr.updated_at
            FROM follower_relationships AS fr
            LEFT JOIN people AS person ON fr.person_id = person.id
            LEFT JOIN people AS follower ON fr.follower_id = follower.id
            WHERE
              person.cloned_from IS NOT NULL AND
              follower.cloned_from IS NULL
      ")
      execute("
        DELETE fr
          FROM follower_relationships AS fr
          LEFT JOIN people AS person
          ON person.id = fr.person_id
          LEFT JOIN people AS follower
          ON follower.id = fr.follower_id
          WHERE
            person.cloned_from IS NOT NULL OR
            follower.cloned_from IS NOT NULL
      ")
    end
  end
end


