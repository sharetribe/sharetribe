class UpdateCategoriesWithPriceAndTranslations < ActiveRecord::Migration[5.2]
def up

    # Skip this at this point as later migration will call it again when there's also payments added, so it won't crash
    #CategoriesHelper.add_custom_price_quantity_placeholders
  end

  def down
  end
end
