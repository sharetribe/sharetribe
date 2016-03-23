class DeleteDuplicateCommunityMemberships < ActiveRecord::Migration
  def up
    execute("
      DELETE community_memberships FROM community_memberships

      # Select the first id (MIN) of duplicated community_memberships
      LEFT JOIN
        (SELECT MIN(id) as first_id, person_id, community_id
        FROM community_memberships
        GROUP BY person_id, community_id
        HAVING count(*) > 1) AS dup
        ON dup.person_id = community_memberships.person_id AND dup.community_id = community_memberships.community_id

      # Delete all the other memberships, except the first one
      WHERE
        dup.person_id = community_memberships.person_id AND
        dup.community_id = community_memberships.community_id AND
        dup.first_id != community_memberships.id
    ")
  end

  def down
    # Nothing to do.
    # The UP migration deletes data, so there's no way to get it back
  end
end
