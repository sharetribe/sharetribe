class UpdateCommentsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    add_index :comments, :author_id
    add_index :comments, :community_id

    execute("
        UPDATE comments AS c, people AS p
        SET c.author_id = p.id
        WHERE
          c.author_id = p.cloned_from AND
          c.community_id = p.community_id
      ")
    remove_index :comments, :author_id
    remove_index :comments, :community_id
  end

  def down
    add_index :comments, :author_id
    add_index :comments, :community_id
    execute("
      UPDATE comments AS c, people AS p
      SET c.author_id = p.cloned_from
      WHERE
        c.author_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
    remove_index :comments, :author_id
    remove_index :comments, :community_id
  end
end
