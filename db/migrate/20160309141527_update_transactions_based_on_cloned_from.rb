class UpdateTransactionsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    add_index :transactions, :starter_id
    add_index :transactions, :listing_author_id
    ActiveRecord::Base.transaction do
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
    remove_index :transactions, :starter_id
    remove_index :transactions, :listing_author_id
  end

  def down
    add_index :transactions, :starter_id
    add_index :transactions, :listing_author_id
    ActiveRecord::Base.transaction do
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
    remove_index :transactions, :starter_id
    remove_index :transactions, :listing_author_id
  end
end
