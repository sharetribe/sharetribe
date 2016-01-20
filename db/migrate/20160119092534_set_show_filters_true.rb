class SetShowFiltersTrue < ActiveRecord::Migration
  def up
    execute("UPDATE custom_fields SET search_filter = TRUE WHERE (type != 'DateField' AND type != 'TextField')")
  end

  def down
    execute("UPDATE custom_fields SET search_filter = FALSE")
  end
end
