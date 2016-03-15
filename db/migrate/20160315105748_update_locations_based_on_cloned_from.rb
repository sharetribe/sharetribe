class UpdateLocationsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
        UPDATE locations AS l, people AS p
        SET l.person_id = p.id
        WHERE
          l.person_id = p.cloned_from AND
          l.community_id = p.community_id
      ")
  end

  def down
    execute("
      UPDATE locations AS l, people AS p
      SET l.person_id = p.cloned_from
      WHERE
        l.person_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
