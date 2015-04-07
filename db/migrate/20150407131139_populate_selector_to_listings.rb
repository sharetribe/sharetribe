class PopulateSelectorToListings < ActiveRecord::Migration
  def up
    execute("UPDATE listings SET quantity_selector_type = 'day' WHERE unit_type = 'day'")
    execute("UPDATE listings SET quantity_selector_type = 'none' WHERE unit_type <> 'day' AND unit_type IS NOT NULL")
  end

  def down
    execute("UPDATE listings SET quantity_selector_type = NULL")
  end
end
