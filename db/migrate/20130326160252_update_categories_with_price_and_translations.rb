class UpdateCategoriesWithPriceAndTranslations < ActiveRecord::Migration
  def up
    CategoriesHelper.update_translations
    CategoriesHelper.add_custom_price_quantity_placeholders
  end

  def down
  end
end
