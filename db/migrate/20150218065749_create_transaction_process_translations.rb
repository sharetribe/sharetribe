class CreateTransactionProcessTranslations < ActiveRecord::Migration
  def up
    create_table :transaction_process_translations do |t|
      t.integer :transaction_process_id, null: false
      t.string :locale, null: false
      t.string :name
      t.string :action_button_label

      t.timestamps null: false
    end

    add_index :transaction_process_translations, :transaction_process_id
    add_index :transaction_process_translations, :locale
  end

  def down
    drop_table :transaction_process_translations
  end
end
