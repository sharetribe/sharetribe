require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class CreateCommunitySpecificCategories < ActiveRecord::Migration

  def up
    puts "Going through #{Community.count} communities and creating needed categories for each:"
    
    Community.order("members_count ASC").find_each do |community|
      categories = community.categories
      main_categories = categories.select{|c| c.parent_id.nil?}
      subcategories = categories.select{|c| ! c.parent_id.nil?}

      custom_community_categories = CommunityCategory.find_by_community_id(community.id)

      # Check if using custom categories
      if custom_community_categories
      

        main_categories.each do |category|
          create_new_cat_and_trans_if_needed(category, community)
        end

        # Second loop sub categories
        subcategories.each do |category|
          create_new_cat_and_trans_if_needed(category, community)
        end

        print_stat "c"

      else # Using default categories

        if community.listings.count == 0
          # No listings at all, create just item and sell
          # TODO
          print_stat "e"
        else
          # Loop all listings and create needed categories and update listing's data
          community.listings.each do |listing|
            #ensure_cat_and_transaction_exist(community, listing)
            #listing.update_column ...
            # TODO
          end
          print_stat "d"
        end

      end

      
    end

  end

  def down
  end


  def ensure_cat_and_transaction_exist(community, listing)
    # TODO
  end

  def create_new_cat_and_trans_if_needed(old_cat, community)

    # FIRST CREATE THE CATEGORY

    if old_cat.parent_id
      # Find new parent, which should be created at this point (Error if not)
      new_parent_id = Category.where(:community_id => community.id, :name => old_cat.parent.name).first.id
    else
      new_parent_id = nil
    end

    if new_cat = Category.find_by_community_id_and_name(community.id, old_cat.name) 
      #Avoid duplicates
      puts "WARNING: category #{old_cat.name} already exists for community_id: #{community.id}"
    else
      new_cat = Category.create(:name => old_cat.name, :parent_id => new_parent_id, :icon => old_cat.icon, :community_id => community.id)
      old_cat.translations.each do |old_trans|
        CategoryTranslation.create!(:category_id => new_cat.id, :locale => old_trans.locale, :name => old_cat.name, :description => old_cat.description)
      end
    end


    # THEN FETCH THE COMMUNITYCATEOGRIES AND CREATE NEEDED TRANSACTIONTYPES

    com_cats_for_this_cat = CommunityCategory.find_all_by_community_id_and_category_id(community.id, old_cat.id)
    if com_cats_for_this_cat.empty?
      # defaults in use
      com_cats_for_this_cat = CommunityCategory.find_all_by_community_id_and_category_id(nil, old_cat.id)
    end

    # Update sort priority based on first com_cat for this category
    new_cat.update_attribute(:sort_priority, com_cats_for_this_cat.first.sort_priority)

    com_cats_for_this_cat.each do |community_category|
      new_type_class = SHARE_TYPE_MAP[community_category.share_type.name]

      if  new_trt = new_type_class.find_by_community_id(community.id)
        puts "WARNING: transaction type #{new_trt.class.name} for community_id: #{community.id} already exists"
      else 
        new_trt = new_type_class.create!(:community_id => community.id, :sort_priority => com_cat.sort_priority, :price_field => com_cat.price)
      end

      create_translations_for(new_trt, community)

      # Link category and transaction type
      CategoryTransactionType.create!(:category_id => new_cat.id, :transaction_type_id => new_trt.id)

    end
    
  end

  # Creates translations for new transaciton type
  def create_translations_for(trans_type, community)

    community.locales.each do |locale|
      if TransactionTypeTranslation.find_by_transaction_type_id_and_locale(trans_type.id, locale)
        puts "WARNING: #{locale} translation for trans_type.id #{trans_type.id} already exists"

      else
        TransactionTypeTranslation.create(:locale => locale, :transaction_type_id => trans_type.id, 
          :name => I18n.t(trans_type.class.downcase, :locale => locale, :scope => ["admin", "transaction_types"]))
      end
    end

  end


  SHARE_TYPE_MAP = {
    "offer" => Service,
    "sell" => Sell,
    "rent_out" => Rent,
    "lend" => Loan,
    "offer_to_swap" => Swap,
    "give_away" => Give,
    "share_for_free" => Service,
    "request" => Request,
    "buy" => Request,
    "rent" => Request,
    "borrow" => Request,
    "request_to_swap" => Swap,
    "receive" => Request,
    "accept_for_free" => Request,
    "sell_material" => Sell,
    "give_away_material" => Give,
    "search_material" => Request,
    "sell_alt" => Sell,
    "offer_to_swap_alt" => Swap,
    "show_collection" => Service,
    "offer_to_barter" => Swap,
    "request_to_barter" => Swap,
    "rent_out_a_bike" => Rent,
    "sell_a_bike" => Sell,
    "get_a_bike" => Request,
    "sell_mass" => Sell,
    "give_away_mass" => Give,
    "search_mass" => Request,
    "offer_job" => Service,
    "request_job" => Request,
    "offer_bf" => Service,
    "request_bf" => Request,
    "give_vg" => Give,
    "ask_vg" => Request,
    "offer_furnished_place" => Rent,
    "free_up_flat_furnished" => Rent,
    "free_up_room_furnished" => Rent,
    "sublet_flat_furnished" => Rent,
    "sublet_room_furnished" => Rent,
    "offer_non_furnished_place" => Rent,
    "free_up_flat_non_furnished" => Rent,
    "free_up_room_non_furnished" => Rent,
    "sublet_flat_non_furnished" => Rent,
    "sublet_room_non_furnished" => Rent,
    "quiero_aprender_conocimientos" => Request,
    "online_apprender" => Request,
    "presencial_apprender" => Request,
    "quiero_ensenar_conocimientos" => Service,
    "online_ensenar" => Service,
    "presencial_ensenar" => Service,
    "request_quiver" => Request,
    "offer_quiver" => Rent,
    "sell_tickets" => Sell,
    "buy_tickets" => Request,
    "request_cf" => Request,
    "offer_cf" => Service,
    "sell_leasing" => Sell,
    "buy_leasing" => Request,
    "ar_give_away" => Give,
    "bb_offer" => Sell,
    "ss_offer_entreegratuite" => Service,
    "ss_offer_entreepayante" => Sell,
    "ss_offer_location" => Rent,
    "ss_offer_miseadispositiongratuite" => Service,
    "ss_request_entreegratuite" => Request,
    "ss_request_entreepayante" => Request,
    "ss_request_location" => Request,
    "ss_request_miseadispositiongratuite" => Request,
    "offer_parking_spots" => Rent,
    "request_parking_spots" => Request,
    "dvotd_sell" => Sell,
  }

end
