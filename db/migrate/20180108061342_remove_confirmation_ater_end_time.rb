class RemoveConfirmationAterEndTime < ActiveRecord::Migration[5.1]
  def change
    remove_column :communities, :automatic_confirmation_after_days_after_end_time, :integer, default: 2
    remove_column :payment_settings, :confirmation_after_days_after_end_time, :integer, default: 2
  end
end
