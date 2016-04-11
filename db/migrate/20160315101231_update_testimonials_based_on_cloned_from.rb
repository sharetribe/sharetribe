class UpdateTestimonialsBasedOnClonedFrom < ActiveRecord::Migration
  def up
    ActiveRecord::Base.transaction do
      # Update author id
      execute("
        UPDATE 
          testimonials AS te,
          transactions AS tr,
          people AS p
        SET te.author_id = p.id
        WHERE
          te.author_id = p.cloned_from AND
          tr.community_id = p.community_id AND
          te.transaction_id = tr.id
      ")

      # Update receiver id
      execute("
        UPDATE 
          testimonials AS te,
          transactions AS tr,
          people AS p
        SET te.receiver_id = p.id
        WHERE
          te.receiver_id = p.cloned_from AND
          tr.community_id = p.community_id AND
          te.transaction_id = tr.id
      ")
    end
  end

  def down
    ActiveRecord::Base.transaction do
      # Roll back author id
      execute("
        UPDATE testimonials AS t, people AS p
        SET t.author_id = p.cloned_from
        WHERE
          t.author_id = p.id AND
          p.cloned_from IS NOT NULL
      ")

      # Roll back receiver id
      execute("
        UPDATE testimonials AS t, people AS p
        SET t.receiver_id = p.cloned_from
        WHERE
          t.receiver_id = p.id AND
          p.cloned_from IS NOT NULL
      ")
    end
  end
end
