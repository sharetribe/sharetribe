module CategoriesHelper

  require File.expand_path('../../../test/helper_modules', __FILE__)
  include TestHelpers

  DEFAULT_TRANSACTION_TYPES_FOR_TESTS = ["Sell", "Give"]

  DEFAULT_CATEGORIES_FOR_TESTS = [
    {
    "item" => [
      "tools",
      "books",
      "furniture",
      "other"
      ]
    },
    "favor",
    "housing" 
  ]

  def self.load_test_categories_and_transaction_types_to_db
    # Create categories and transaction types for the 3 default text
    # communities defined in fixtures.
    Community.find_each { |c| c.destroy }
    ["test", "test2", "test3"].each do |domain|
      community = Community.create!(:name => domain, :domain => domain, :settings => {"locales" => ["en", "fi"]})
      community.categories.each { |c| c.destroy }
      community.transaction_types.each { |t| t.destroy }
      CategoriesHelper.load_categories_and_transaction_types_to_db(community, DEFAULT_TRANSACTION_TYPES_FOR_TESTS, DEFAULT_CATEGORIES_FOR_TESTS)
    end
  end

  def self.load_categories_and_transaction_types_to_db(community, transaction_types, categories)

    # Load transaction types
    transaction_types.each do |tt|
      transaction_type = TransactionType.create!(:type => tt, :community_id => community.id)
      community.locales.each do |locale|
        tt_name = I18n.t!(tt.underscore, :locale => locale, :scope => ["admin", "transaction_types"], :raise => true)
        transaction_type.translations.create!(:locale => locale, :name => tt_name)
      end
    end

    # Load categories
    categories.each do |c|

      # Categories that do not have subcategories
      if c.is_a?(String)
        category = Category.create!(:community_id => community.id)
        CategoriesHelper.add_transaction_types_and_translations_to_category(category, c)

      # Categories that have subcategories
      elsif c.is_a?(Hash)
        puts "C (hash): #{c.inspect}"
        top_level_category = Category.create!(:community_id => community.id)
        puts "Top level category: #{top_level_category}"
        CategoriesHelper.add_transaction_types_and_translations_to_category(top_level_category, c.keys.first)
        c.values.first.each do |sg|
          subcategory = Category.create!(:community_id => community.id, :parent_id => top_level_category.id)
          CategoriesHelper.add_transaction_types_and_translations_to_category(subcategory, sg)
        end
      end

    end
  end

  def self.add_transaction_types_and_translations_to_category(category, category_name)
    category.community.transaction_types.each { |tt| category.transaction_types << tt }
    category.community.locales.each do |locale|
      puts "Category name: #{category_name}"
      cat_name = I18n.t!(category_name, :locale => locale, :scope => ["common", "categories"], :raise => true)
      category.translations.create!(:locale => locale, :name => cat_name)
    end
  end










  
  def self.load_default_categories_to_db(params={})
    load_categories_and_share_types_to_db(:community_id => nil, :categories => DEFAULT_CATEGORIES, :share_types => DEFAULT_SHARE_TYPES)

    add_custom_price_quantity_placeholders unless params[:without_price_updates]
    update_default_rent_out_quantity_placeholder # Just a small change to default categorization
  end
  
  # Usage:
  # CategoriesHelper.load_categories_and_share_types_to_db(:community => c, :categories => categories, :share_types => share_types, :translations => custom_translations)
  
  
  def self.load_categories_and_share_types_to_db(params={})
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
      s =  ShareType.find_by_name(share_type) || ShareType.create(:name => share_type, :icon => (details[:icon] || share_type), :parent => parent, :transaction_type => details[:transaction_type])
      details[:categories].each do |category_name|
        c = Category.find_by_name(category_name)
        CommunityCategory.create(:category => c, :share_type => s, :community_id => community_id, :price => details[:price], :payment => details[:payment], :price_quantity_placeholder => details[:price_quantity_placeholder]) if c && ! CommunityCategory.find_by_category_id_and_share_type_id_and_community_id(c.id, s.id, community_id)
      end
      s.update_attribute(:transaction_type, s.name) if ["offer","request"].include? s.name
    end
    
    update_translations(:translations => translations) unless params[:skip_translations]
    
  end
  
  def self.update_translations(params={})
    translations = params[:translations] || {}
    # Store translations for all that can be found from translation files
    Kassi::Application.config.AVAILABLE_LOCALES.each do |loc|
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
            existing_translation.update_attribute(:description, translated_description) unless params[:without_description_translations]
          else
            unless params[:without_description_translations]
              CategoryTranslation.create(:category => category, :locale => locale, :name => translated_name, :description => translated_description) 
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
            existing_translation.update_attribute(:description, translated_description) unless params[:without_description_translations]
          else
            unless params[:without_description_translations]
              ShareTypeTranslation.create(:share_type => share_type, :locale => locale, :name => translated_name, :description => translated_description) 
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

  
  def self.add_custom_price_quantity_placeholders
    sell = ShareType.find_by_name("sell")
    rent_out = ShareType.find_by_name("rent_out")
    item = Category.find_by_name("item")
    housing = Category.find_by_name("housing")
    buy =ShareType.find_by_name("buy")
    rent = ShareType.find_by_name("rent")
    
    sell_item = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", item.id.to_s, sell.id.to_s).first
    sell_item.update_attributes(:price => true, :payment => true)
    
    rent_out_item = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", item.id.to_s, rent_out.id.to_s).first
    rent_out_item.update_attributes(:price => true, :price_quantity_placeholder => "time", :payment => true)
    
    buy_item = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", item.id.to_s, buy.id.to_s).first
    buy_item.update_attributes(:payment => true)
    
    rent_item = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", item.id.to_s, rent.id.to_s).first
    rent_item.update_attributes(:payment => true)
    
    sell_housing = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", housing.id.to_s, sell.id.to_s).first
    sell_housing.update_attributes(:price => true, :payment => true)
    
    rent_out_housing = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", housing.id.to_s, rent_out.id.to_s).first
    rent_out_housing.update_attributes(:price => true, :price_quantity_placeholder => "long_time", :payment => true)
    
    buy_housing = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", housing.id.to_s, buy.id.to_s).first
    buy_housing.update_attributes(:payment => true)
    
    rent_housing = CommunityCategory.where("category_id = ? AND share_type_id = ? AND community_id IS NULL", housing.id.to_s, rent.id.to_s).first
    rent_housing.update_attributes(:payment => true)
    
  end
  
  def self.update_default_rent_out_quantity_placeholder
    # This custom line sets the default housing rent_out offer to 
    # have price_quantity_placeholder "long_time" instead of the normal time :)
    CommunityCategory.find_by_category_id_and_share_type_id_and_community_id(Category.find_by_name("housing").id, ShareType.find_by_name("rent_out").id, nil).update_attribute(:price_quantity_placeholder, "long_time")
  end
  
  def self.remove_all_categories_from_db
    Category.delete_all
    CategoryTranslation.delete_all
    ShareType.delete_all
    ShareTypeTranslation.delete_all
    CommunityCategory.delete_all
  end
  
end