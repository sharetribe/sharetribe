class UpdateListingsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
        UPDATE listings AS l, people AS p
        SET l.author_id = p.id
        WHERE
          l.author_id = p.cloned_from AND
          l.community_id = p.community_id
      ")
  end

  def down
    execute("
      UPDATE listings AS l, people as p
      SET l.author_id = p.cloned_from
      WHERE
        l.author_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
