class AddUnitSelectorTranslationToTransactions < ActiveRecord::Migration
  def change
    add_column :transactions, :unit_selector_tr_key, :string, limit: 64, after: :unit_tr_key
  end
end
