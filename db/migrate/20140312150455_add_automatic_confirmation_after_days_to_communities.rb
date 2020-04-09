class AddAutomaticConfirmationAfterDaysToCommunities < ActiveRecord::Migration[5.2]
def change
    add_column :communities, :automatic_confirmation_after_days, :int, :default => 14
  end
end
