class AddDefaultCategories < ActiveRecord::Migration[5.2]
  def up
  end

  def down
    puts "THIS MIGRATION ADDS DEFAULT CATEGORIES IF NOT ALREADY IN DB. SO ROLLBACK WON'T DELETE THOSE."
  end
end
