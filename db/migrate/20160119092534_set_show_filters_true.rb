class SetShowFiltersTrue < ActiveRecord::Migration
  def up
    execute("UPDATE custom_fields SET show_filter = TRUE WHERE type != 'DateField'")
  end

  def down
    execute("UPDATE custom_fields SET show_filter = FALSE")
  end
end
