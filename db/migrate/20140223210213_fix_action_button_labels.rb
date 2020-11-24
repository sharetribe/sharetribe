class FixActionButtonLabels < ActiveRecord::Migration
  def up
    TransactionTypeTranslation.find_each do |translation|
      
      transaction_type = translation.transaction_type
      
      if transaction_type.class == Sell || transaction_type.class == Rent
        translation_key = transaction_type.class.name.downcase
      else
        translation_key = transaction_type.direction
      end

      translated_label = I18n.t(translation_key, :locale => translation.locale, :scope => ["admin", "transaction_types", "default_action_button_labels"])
      puts "updating translation #{translation.name} to have label #{translated_label}"
      translation.update_column(:action_button_label, translated_label)
    end
  end

  def down
    raise  ActiveRecord::IrreversibleMigration, "Reverse migration not implemented\n"
  end
end
