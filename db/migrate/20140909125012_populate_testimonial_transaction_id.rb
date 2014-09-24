class PopulateTestimonialTransactionId < ActiveRecord::Migration
  def up
    execute("UPDATE testimonials
      INNER JOIN participations ON (testimonials.participation_id = participations.id)
      INNER JOIN conversations ON (participations.conversation_id = conversations.id)
      INNER JOIN transactions ON (transactions.conversation_id = conversations.id)
      SET transaction_id = transactions.id
      WHERE participation_id = participations.id
    ")
  end

  def down
    execute("UPDATE testimonials
      INNER JOIN transactions ON (testimonials.transaction_id = transactions.id)
      INNER JOIN conversations ON (conversations.id = transactions.conversation_id)
      INNER JOIN participations ON (participations.conversation_id = conversations.id)
      SET testimonials.participation_id = participations.id
      WHERE participations.person_id = testimonials.author_id")

    execute("UPDATE testimonials SET transaction_id = NULL WHERE transaction_id IS NOT NULL")
  end
end
