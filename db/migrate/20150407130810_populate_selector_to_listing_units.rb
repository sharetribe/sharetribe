class PopulateSelectorToListingUnits < ActiveRecord::Migration
  def up
    execute("UPDATE listing_units SET quantity_selector = 'day' WHERE unit_type = 'day'")
    execute("UPDATE listing_units SET quantity_selector = 'none' WHERE unit_type <> 'day'")
  end

  def down
    execute("UPDATE listing_units SET quantity_selector = 'none'") # can not rollback to non-value since null is not accepted
  end
end
