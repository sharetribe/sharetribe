class AddTransactionButtonTextToShareTypeTranslations < ActiveRecord::Migration[5.2]
  def change
    add_column :share_type_translations, :transaction_button_text, :string
  end
end
