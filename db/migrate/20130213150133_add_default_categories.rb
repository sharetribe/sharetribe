class AddDefaultCategories < ActiveRecord::Migration


  def up
    load_default_categories_to_db({:without_description_translations => true, :without_price_updates => true})
    # the above method was changed too much to run this migration on older installations so copy the relevant code here
  end

  def down
    puts "THIS MIGRATION ADDS DEFAULT CATEGORIES IF NOT ALREADY IN DB. SO ROLLBACK WON'T DELETE THOSE."
  end


  DEFAULT_CATEGORIES = [
    {
    "item" => [
      "tools",
      "sports",
      "music",
      "books",
      "games",
      "furniture",
      "outdoors",
      "food",
      "electronics",
      "pets",
      "film",
      "clothes",
      "garden",
      "travel",
      "other"
      ]
    },
    "favor",
    "rideshare",
    "housing"
  ]

  DEFAULT_SHARE_TYPES = {
    "offer" => {:categories => ["item", "favor", "rideshare", "housing"]},
      "sell" => {:parent => "offer", :categories => ["item", "housing"], :price => true, :payment => true},
      "rent_out" => {:parent => "offer", :categories => ["item", "housing"], :price => true, :payment => true, :price_quantity_placeholder => "time"},
      "lend" => {:parent => "offer", :categories => ["item"]},
      "offer_to_swap" => {:parent => "offer", :categories => ["item"]},
      "give_away" => {:parent => "offer", :categories => ["item"]},
      "share_for_free" => {:parent => "offer", :categories => ["housing"]},

    "request" => {:categories => ["item", "favor", "rideshare", "housing"]},
      "buy" => {:parent => "request", :categories => ["item", "housing"], :payment => true},
      "rent" => {:parent => "request", :categories => ["item", "housing"], :payment => true},
      "borrow" => {:parent => "request", :categories => ["item"]},
      "request_to_swap" => {:parent => "request", :categories => ["item"]},
      "receive" => {:parent => "request", :categories => ["item"]},
      "accept_for_free" => {:parent => "request", :categories => ["housing"]}
  }

  def load_default_categories_to_db(params={})
    load_categories_and_share_types_to_db(:community_id => nil, :categories => DEFAULT_CATEGORIES, :share_types => DEFAULT_SHARE_TYPES)

  end

  # Usage:
  # CategoriesHelper.load_categories_and_share_types_to_db(:community => c, :categories => categories, :share_types => share_types, :translations => custom_translations)


  def load_categories_and_share_types_to_db(params={})
    community_id = params[:community_id] || (params[:community] ? params[:community].id : nil)
    categories = params[:categories]
    share_types = params[:share_types]
    translations = params[:translations]

    categories.each do |category|
      if category.class == String
        Category.create([{:name => category, :icon => category}]) unless Category.find_by_name(category)
      elsif category.class == Hash
        parent = Category.find_by_name(category.keys.first) || Category.create(:name => category.keys.first, :icon => category.keys.first)
        category.values.first.each do |subcategory|
          c = Category.find_by_name(subcategory) || Category.create({:name => subcategory, :icon => subcategory, :parent_id => parent.id})
          # As subcategories won't get their own link to share_types (as they inherit that from parent category)
          # We create a CommunityCategory entry here to mark that these subcategories exist in the default tribe
          CommunityCategory.create(:category => c, :community_id => community_id) unless CommunityCategory.find_by_category_id_and_community_id(c.id, community_id)
        end
      else
        puts "Invalid data for categories. It must be array of Strings and Hashes."
        return
      end
    end

    share_types.each do |share_type, details|
      parent = ShareType.find_by_name(details[:parent]) if details[:parent]
      s =  ShareType.find_by_name(share_type) || ShareType.create(:name => share_type, :icon => (details[:icon] || share_type), :parent => parent)
      details[:categories].each do |category_name|
        c = Category.find_by_name(category_name)
        CommunityCategory.create(:category => c, :share_type => s, :community_id => community_id) if c && ! CommunityCategory.find_by_category_id_and_share_type_id_and_community_id(c.id, s.id, community_id)
      end

    end

    update_translations(:translations => translations) unless params[:skip_translations]

  end

  def update_translations(params={})
    translations = params[:translations] || {}
    # Store translations for all that can be found from translation files
    Rails.application.config.AVAILABLE_LOCALES.each do |loc|
      locale = loc[1]
      Category.find_each do |category|
        begin
          translated_name = (translations[locale] && translations[locale][category.name]) || I18n.t!(category.name, :locale => locale, :scope => ["common", "categories"], :raise => true)

          begin
            translated_description = (translations[locale] && translations[locale][:descriptions] && translations[locale][:descriptions][category.name]) || I18n.t!(category.name, :locale => locale, :scope => ["listings", "new"], :raise => true)
          rescue
            translated_description = nil #if description is nil, still continue to translate the name
          end

          existing_translation = CategoryTranslation.find_by_category_id_and_locale(category.id, locale)
          if existing_translation
            existing_translation.update_attribute(:name, translated_name)
          else
            unless params[:without_description_translations]
              CategoryTranslation.create(:category => category, :locale => locale, :name => translated_name)
            else
              CategoryTranslation.create(:category => category, :locale => locale, :name => translated_name)
            end
          end
        rescue I18n::MissingTranslationData
          # no need to store anything if no translation found
        end
      end


      ShareType.find_each do |share_type|
        share_type_name = share_type.name
        #see if the name ends with "_alt\d*" meaning that it's an alternative share_type in the DB but can use the same translations as the original
        if share_type_name.match(/_alt\d*$/)
          share_type_name = share_type_name.split("_alt").first
        end
        begin
          translated_name = (translations[locale] && translations[locale][share_type_name]) || I18n.t!(share_type_name, :locale => locale, :scope => ["common", "share_types"], :raise => true)

          begin
            translated_description = (translations[locale] && translations[locale][:descriptions] && translations[locale][:descriptions][share_type_name]) || I18n.t!(share_type_name, :locale => locale, :scope => ["listings", "new"], :raise => true)
          rescue
            translated_description = nil #if description is nil, still continue to translate the name
          end
          existing_translation = ShareTypeTranslation.find_by_share_type_id_and_locale(share_type.id, locale)
          if existing_translation
            existing_translation.update_attribute(:name, translated_name)
          else
            unless params[:without_description_translations]
              ShareTypeTranslation.create(:share_type => share_type, :locale => locale, :name => translated_name)
            else
              ShareTypeTranslation.create(:share_type => share_type, :locale => locale, :name => translated_name)
            end
          end
        rescue I18n::MissingTranslationData
          # no need to store anything if no translation found
        end
      end
    end
  end
end
