class MigrateListingIdsToCustomFieldOptionSelections < ActiveRecord::Migration

  # Run this population script after all the code changes are deployed first
  def up
    execute("
      UPDATE custom_field_option_selections os, custom_field_values cfv
      SET os.listing_id = cfv.listing_id
      WHERE cfv.id = os.custom_field_value_id;
    ")
  end

end
