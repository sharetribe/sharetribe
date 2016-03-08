class UpdateInvitationsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
        UPDATE invitations AS inv, people AS p
        SET inv.inviter_id = p.id
        WHERE
          inv.inviter_id = p.cloned_from AND
          inv.community_id = p.community_id
      ")
  end

  def down
    execute("
      UPDATE invitations AS inv, people as p
      SET inv.inviter_id = p.cloned_from
      WHERE
        inv.inviter_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
