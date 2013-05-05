class AddTransactionButtonTextToShareTypeTranslations < ActiveRecord::Migration
  def change
    add_column :share_type_translations, :transaction_button_text, :string
  end
end
