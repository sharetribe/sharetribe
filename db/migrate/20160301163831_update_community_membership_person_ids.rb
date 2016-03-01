class UpdateCommunityMembershipPersonIds < ActiveRecord::Migration
  def up
    cloned_people = select_all("
        SELECT id, cloned_from FROM people WHERE cloned_from IS NOT NULL
      ").to_ary
    cloned_people.each do |p|
      membership = select_one("
        SELECT id FROM community_memberships WHERE person_id = #{quote(p['cloned_from'])}
      ")
      execute("
        UPDATE community_memberships
        SET person_id = #{quote(p['id'])}
        WHERE id = #{quote(membership['id'])}
      ")
    end 
  end
  def down
    execute("
      UPDATE community_memberships AS cm, people AS p
      SET cm.person_id = p.cloned_from
      WHERE
        p.id = cm.person_id AND
        p.cloned_from IS NOT NULL
    ") 
  end
end
