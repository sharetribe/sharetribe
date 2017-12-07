class AddAutomaticConfirmationAfterDaysAfterEndTimeToCommunities < ActiveRecord::Migration[5.1]
  def change
    add_column :communities, :automatic_confirmation_after_days_after_end_time, :integer, default: 2
  end
end
