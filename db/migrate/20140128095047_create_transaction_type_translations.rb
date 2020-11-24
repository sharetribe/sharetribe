class CreateTransactionTypeTranslations < ActiveRecord::Migration
  def change
    create_table :transaction_type_translations do |t|
      t.integer :transaction_type_id
      t.string :locale
      t.string :name
      t.string :action_button_label

      t.timestamps
    end
  end
end
