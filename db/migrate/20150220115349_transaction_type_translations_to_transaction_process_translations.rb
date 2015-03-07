class TransactionTypeTranslationsToTransactionProcessTranslations < ActiveRecord::Migration
  def up
    execute("
      INSERT INTO transaction_process_translations (transaction_process_id, locale, name, action_button_label, created_at, updated_at)
      (
        SELECT tp.id, ttt.locale, ttt.name, ttt.action_button_label, ttt.created_at, ttt.updated_at
        FROM transaction_processes as tp
        LEFT JOIN listing_shapes as ls ON (tp.listing_shape_id = ls.id)
        LEFT JOIN transaction_type_translations as ttt ON (ls.transaction_type_id = ttt.transaction_type_id)
        WHERE tp.id NOT IN (SELECT transaction_process_id FROM transaction_process_translations)

      )
")

  def down
    execute("
      DELETE FROM transaction_process_translations
")
  end
end
