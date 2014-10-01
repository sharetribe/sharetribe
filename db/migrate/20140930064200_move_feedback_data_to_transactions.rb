class MoveFeedbackDataToTransactions < ActiveRecord::Migration
  def up
    execute("UPDATE transactions t
      INNER JOIN participations p ON (t.conversation_id = p.conversation_id)
      SET t.starter_skipped_feedback = p.feedback_skipped
      WHERE (p.is_starter = TRUE);")

    execute("UPDATE transactions t
      INNER JOIN participations p ON (t.conversation_id = p.conversation_id)
      SET t.author_skipped_feedback = p.feedback_skipped
      WHERE (p.is_starter = FALSE)")
  end

  def down
    execute("UPDATE participations p
     INNER JOIN transactions t ON (p.conversation_id = t.conversation_id)
     SET p.feedback_skipped = t.starter_skipped_feedback
     WHERE t.starter_id = p.person_id AND p.is_starter = TRUE")

    execute("UPDATE participations p
      INNER JOIN transactions t ON (p.conversation_id = t.conversation_id)
      SET p.feedback_skipped = t.author_skipped_feedback
      WHERE t.starter_id != p.person_id AND p.is_starter = FALSE")

    execute("UPDATE transactions t
      SET t.starter_skipped_feedback = 0,
          t.author_skipped_feedback = 0")
  end
end
