class InitializeCategoryUrls < ActiveRecord::Migration
  def up
    Category.reset_column_information
    Category.initialize_urls
  end

  def down
  end
end
