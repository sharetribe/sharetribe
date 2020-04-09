class PopulateTransactionTypeTranslationKeys < ActiveRecord::Migration[5.2]
def up
    execute("UPDATE transaction_types
      SET name_tr_key = CONCAT('transaction_type_translation.name.', id),
          action_button_tr_key = CONCAT('transaction_type_translation.action_button_label.', id)")
  end

  def down
  end
end
