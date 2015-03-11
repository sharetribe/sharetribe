class NullConstrainAutomaticConfirmationAfterDays < ActiveRecord::Migration
  def change
    change_column :transactions, :automatic_confirmation_after_days, :int, null: false
  end
end
