class UpdateParticipationsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
        UPDATE participations AS part, conversations AS c, people AS p
        SET part.person_id = p.id
        WHERE
          part.person_id = p.cloned_from AND
          c.community_id = p.community_id AND
          part.conversation_id = c.id
      ")
  end

  def down
    execute("
      UPDATE participations AS part, people as p
      SET part.person_id = p.cloned_from
      WHERE
        part.person_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
