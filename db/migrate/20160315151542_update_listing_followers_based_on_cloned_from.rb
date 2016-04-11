class UpdateListingFollowersBasedOnClonedFrom < ActiveRecord::Migration
  def up
    execute("
      UPDATE listing_followers AS lf, listings AS l, people AS p
      SET lf.person_id = p.id
      WHERE
        lf.person_id = p.cloned_from AND
        l.community_id = p.community_id AND
        lf.listing_id = l.id
    ")
  end

  def down
    execute("
      UPDATE listing_followers AS lf, people AS p
      SET lf.person_id = p.cloned_from
      WHERE
        lf.person_id = p.id AND
        p.id IS NOT NULL
    ")
  end
end
