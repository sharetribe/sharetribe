class AddAutomaticConfirmationAfterDaysToCommunities < ActiveRecord::Migration
  def change
    add_column :communities, :automatic_confirmation_after_days, :int
  end
end
