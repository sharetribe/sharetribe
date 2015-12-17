require File.expand_path('../../migrate_helpers/logging_helpers', __FILE__)

class CreateCommunitySpecificCategories < ActiveRecord::Migration
  include LoggingHelper

  def up
    puts "Going through #{Community.count} communities and creating needed categories for each:"
    
    Community.order("members_count ASC").each do |community|

      if community.settings["categories_migrated"]
        puts "\nSkipping community #{community.domain} (already migrated)\n"
      else
        puts "\n\n\nUpdating community #{community.domain}\n"

        # puts "Are you sure you want to continue? (y/n)"
        # response = STDIN.gets.strip
        # exit if response != 'y' && response != 'Y'

        categories = community.categories
        main_categories = categories.select{|c| c.parent_id.nil?}
        subcategories = categories.select{|c| ! c.parent_id.nil?}

        custom_community_categories = CommunityCategory.find_by_community_id(community.id)


        if custom_community_categories || community.listings.count > 0      

          puts "Updating Main Categories"
          # Loop main categories first, so that parents are done when getting to sub categories
          main_categories.each do |category|
            #puts "updating cat: #{category.name}"
            new_category = create_new_cat_and_trans_if_needed(category, community)          
          end

          puts "Updating Sub Categories"
          # Second loop sub categories
          subcategories.each do |category|
            #puts "updating cat: #{category.name}"
            new_category = create_new_cat_and_trans_if_needed(category, community)
          end

          puts "UPDATING LISTINGS FOR COMMUNITY #{community.domain}\n"
          # update listings 
          community.listings.each do |listing|
            current_category = listing.category
            if current_category.nil?
              puts "***ERROR*** Listing(#{listing.id} has a category_id without a category -> Skipping updating that listing."
              next
            end
            target_category = Category.find_by_community_id_and_name(community.id, listing.category.name)
            
            if target_category.nil?
              puts "***ERROR*** Listing(#{listing.id} had a category #{listing.category.name} which hasn't been created for #{community.domain} -> removing that listing from community."
              listing.communities.delete(community)
              next
            end

            listing.update_column(:new_category_id, target_category.id )

            if listing.share_type
              transaction_type_class = SHARE_TYPE_MAP[listing.share_type.name]
              target_transaction_type = transaction_type_class.find_by_community_id(community.id)
            end

            if target_transaction_type.nil?
              puts "***ERROR*** Listing(#{listing.id} had a transaction_type #{transaction_type_class} which hasn't been created for #{community.domain} -> removing that listing from community."
              listing.communities.delete(community)
              next
            end
            
            listing.update_column(:transaction_type_id, target_transaction_type.id)
            print_dot

          end

          puts ""

          if custom_community_categories
            # Keep even empty categories if they are customized
            print_stat "c"
          else
            # Default categories, we'll keep only those which had listings

            new_categories = Category.where(community_id: community.id)
            new_main_categories = new_categories.select{|c| c.parent_id.nil?}
            new_subcategories   = new_categories.select{|c| ! c.parent_id.nil?}

            new_subcategories.each do |cat|
              if Listing.find_by_new_category_id(cat.id).nil?
                puts "Will delete subcategory #{cat.name} for community #{community.domain}"
                cat.destroy
              end
            end

            new_main_categories.each do |cat|
              if Listing.find_by_new_category_id(cat.id).nil? && Category.find_by_parent_id(cat.id).nil?
                puts "Will delete main category #{cat.name} for community #{community.domain}"
                cat.destroy
              end
            end

            print_stat "d"
          end

        else # Using default categories and having 0 listings
          crete_minimum_category_set(community)
          print_stat "e"
        end
      
        community.settings["categories_migrated"] = true
        community.save!
      end
    end

  end



  def create_new_cat_and_trans_if_needed(old_cat, community)

    # FIRST CREATE THE CATEGORY

    if old_cat.parent_id
      # Find new parent, which should be created at this point (Error if not)
       new_parent = Category.where(:community_id => community.id, :name => old_cat.parent.name).first
       if new_parent
        new_parent_id = new_parent.id
      else
        puts "***ERROR*** Parent should be #{old_cat.parent.name} but it's not created for community: #{community.domain} -> Creating the category without parent."        
        new_parent_id = nil
      end
    else
      new_parent_id = nil
    end

    if new_cat = Category.find_by_community_id_and_name(community.id, old_cat.name) 
      #Avoid duplicates
      puts "WARNING: category #{old_cat.name} already exists for community: #{community.domain}"
    else
      puts "creating category #{old_cat.name} for community: #{community.domain}"
      new_cat = Category.create!(:name => old_cat.name, :parent_id => new_parent_id, :icon => old_cat.icon, :community_id => community.id)
      old_cat.translations.each do |old_trans|
        CategoryTranslation.create!(:category_id => new_cat.id, :locale => old_trans.locale, :name => old_trans.name, :description => old_trans.description)
      end
    end


    # THEN FETCH THE COMMUNITYCATEOGRIES AND CREATE NEEDED TRANSACTIONTYPES

    com_cats_for_this_cat = CommunityCategory.where(community_id: community.id, category_id: old_cat.id)
    if com_cats_for_this_cat.empty?
      # defaults in use
      com_cats_for_this_cat = CommunityCategory.where(community_id: nil, category_id: old_cat.id)
    end

    # Update sort priority based on first com_cat for this category
    
    new_cat.update_attribute(:sort_priority, com_cats_for_this_cat.first.sort_priority) if com_cats_for_this_cat.first
    

    com_cats_for_this_cat.each do |community_category|
      if community_category.share_type  # Some com_cats don't have share_type. Skip those as it should be handled already with parent
        #puts "Fetching mapping for old share type #{community_category.share_type.name}"
        new_type_class = SHARE_TYPE_MAP[community_category.share_type.name]

        if new_trt = new_type_class.find_by_community_id(community.id)
          #puts "WARNING: transaction type #{new_trt.class.name} for community: #{community.domain} already exists"
        else 
          price_field_enabled = (new_type_class == Request ? false : community_category.price) # no price field for requests now
          puts "creating transaction type #{new_type_class.name} for community: #{community.domain} price_field(#{price_field_enabled})"
          new_trt = new_type_class.create!(:community_id => community.id, :sort_priority => community_category.sort_priority, :price_field => price_field_enabled)
          create_translations_for(new_trt, community, community_category.share_type)
        end

        

        # Link category and transaction type if needed
        unless CategoryTransactionType.find_by_category_id_and_transaction_type_id(new_cat.id, new_trt.id)
          CategoryTransactionType.create!(:category_id => new_cat.id, :transaction_type_id => new_trt.id)
        end
      else
        # This com_cat doesn't have share type. Reason usually is that it's a subcategory and should be linked to parent's share types

        CategoryTransactionType.where(category_id: new_parent_id).each do |parents_ctt|
          # Link category and transaction type
          CategoryTransactionType.create!(:category_id => new_cat.id, :transaction_type_id => parents_ctt.transaction_type_id)
        end
      end
    end

    return new_cat
    
  end




  # Creates translations for new transaciton type
  def create_translations_for(trans_type, community, old_share_type=nil)

    community.locales.each do |locale|
      if TransactionTypeTranslation.find_by_transaction_type_id_and_locale(trans_type.id, locale)
        puts "WARNING: #{locale} translation for trans_type.id #{trans_type.id} already exists"

      else 

        old_default_names = ["offer", "sell", "rent_out", "lend", "offer_to_swap", "give_away", "share_for_free", "request", "buy", "rent", "borrow", "request_to_swap", "receive", "accept_for_free"]
        
        # quite many share types are merged to request so in those cases just use the translation for request
        # Generally: the old translation is only used for custom share_types

        if trans_type.class != Request && old_share_type && ! old_default_names.include?(old_share_type.name)  && old_translation = ShareTypeTranslation.find_by_share_type_id_and_locale(old_share_type.id, locale)
          translated_name = old_translation.name
        else
          translated_name = I18n.t(trans_type.class.name.downcase, :locale => locale, :scope => ["admin", "transaction_types"])
        end



        TransactionTypeTranslation.create(:locale => locale, :transaction_type_id => trans_type.id, 
          :name => translated_name)
      end
    end

  end

  def crete_minimum_category_set(community)
    
    # Create Item

    old_cat = Category.find_by_community_id_and_name(nil, "item")
    if new_cat = Category.find_by_community_id_and_name(community.id, old_cat.name)
      puts "WARNING: category #{old_cat.name} already exists for community: #{community.domain}"
    else
      new_cat = Category.create!(:name => "item", :parent_id => nil, :icon => "item", :community_id => community.id)
      community.locales.each do |locale|
        old_trans = CategoryTranslation.find_by_category_id_and_locale(old_cat.id, locale)
        CategoryTranslation.create!(:category_id => new_cat.id, :locale => old_trans.locale, :name => old_trans.name, :description => old_trans.description)
      end
    end

    # Create Sell

    new_trt = Sell.create!(:community_id => community.id, :price_field => true)
    create_translations_for(new_trt, community)

    # Link them
    CategoryTransactionType.create!(:category_id => new_cat.id, :transaction_type_id => new_trt.id)    

  end




  SHARE_TYPE_MAP = {
    "offer" => Service,
    "sell" => Sell,
    "rent_out" => Rent,
    "lend" => Lend,
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
    "mm_sell" => Sell,
    "buy_alt" => Request,
  }



  def down
    puts "This is too complicated migration to reverse completely \
    Reversing the migration does delete all new categories (which have community_id) and all transaction types, \
    but it won't reverse the updated listing columns."
    # raise  ActiveRecord::IrreversibleMigration, "This is too comlicated migration to reverse \
    # Although it generally only adds data, and doesn't delete anything, but listings and custom \
    # fields are linked to new categories and transaction types."

    Category.where("community_id IS NOT NULL").each(&:destroy)
    TransactionType.find_each(&:destroy)
    Community.order("members_count ASC").each do |community|
      community.settings.delete("categories_migrated")
      community.save
      print_dot
    end


  end

end
