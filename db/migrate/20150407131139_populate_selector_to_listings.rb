class PopulateSelectorToListings < ActiveRecord::Migration[5.2]
def up
    execute("UPDATE listings SET quantity_selector = 'day' WHERE unit_type = 'day'")
    execute("UPDATE listings SET quantity_selector = 'none' WHERE unit_type <> 'day' AND unit_type IS NOT NULL")
  end

  def down
    execute("UPDATE listings SET quantity_selector = NULL")
  end
end
