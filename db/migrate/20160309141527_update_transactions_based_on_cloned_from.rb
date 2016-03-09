class UpdateTransactionsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    # Update starter id
    execute("
        UPDATE transactions AS t, people AS p
        SET t.starter_id = p.id
        WHERE
          t.starter_id = p.cloned_from AND
          t.community_id = p.community_id
      ")

    # Update listing author id
    execute("
        UPDATE transactions AS t, listings AS l
        SET t.listing_author_id = l.author_id
        WHERE
          t.listing_id = l.id
      ")
  end

  def down
    # Roll back starter id
    execute("
      UPDATE transactions AS t, people AS p
      SET t.starter_id = p.cloned_from
      WHERE
        t.starter_id = p.id AND
        p.cloned_from IS NOT NULL
    ")

    #Roll back listing author id
    execute("
      UPDATE transactions AS t, people AS p
      SET t.listing_author_id = p.cloned_from
      WHERE
        t.listing_author_id = p.id AND
        p.cloned_from IS NOT NULL
    ")
  end
end
