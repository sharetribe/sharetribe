class UpdateFeedbackAuthorIdBasedOnClonedFrom < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      cloned_people = select_all("
         SELECT id, cloned_from, community_id FROM people WHERE cloned_from IS NOT NULL
      ").to_ary
      cloned_people.each { |p|
        execute("
          UPDATE feedbacks SET author_id = #{quote(p['id'])}
          WHERE community_id = #{quote(p['community_id'])} AND author_id = #{quote(p['cloned_from'])}
        ")
      }
    end
  end

  def down
    execute("
      UPDATE feedbacks AS f, people AS p
      SET f.author_id = p.cloned_from
      WHERE
        f.author_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
