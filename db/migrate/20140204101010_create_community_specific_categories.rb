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
          create_new_cat_and_trans_if_needed(category, community.id)

          # A luo cat jos tarvii
          # B Luo trans type jos tarvii
          # C linkitä noi jos tarvii

          # D transalations mukanan
          # E Community id mukana
        end

        # Second loop sub categories
        subcategories.each do |category|
          create_new_cat_and_trans_if_needed(category, community.id)
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

  def create_new_cat_and_trans_if_needed(old_cat, community_id)
    if old_cat.parent_id
      # Find new parent, which should be created at this point (Error if not)
      new_parent_id = Category.where(:community_id => community_id, :name => old_cat.parent.name).first.id
    else
      new_parent_id = nil
    end

    if new_cat = Category.find_by_community_id_and_name(community_id, old_cat.name) 
      #Avoid duplicates
      puts "WARNING: category #{old_cat.name} already exists for community_id: #{community_id}"

    else
      new_cat = Category.create(:name => old_cat.name, :parent_id => new_parent_id, :icon => old_cat.icon, :community_id => community_id)
      # TODO Translations
    end

    com_cats_for_this_cat = CommunityCategory.find_all_by_community_id_and_category_id(community_id, old_cat.id)
    if com_cats_for_this_cat.empty?
      # defaults in use
      com_cats_for_this_cat = CommunityCategory.find_all_by_community_id_and_category_id(nil, old_cat.id)
    end

    com_cats_for_this_cat.each do |community_category|

      new_type_class = get_new_type_based_on_old(community_category.share_type)

      if  new_trt = new_type_class.find_by_community_id(community_id)


      else 
        new_trt = new_type_class.create(:community_id => community_id, :sort_priority => com_cat.sort_priority, :price_field => com_cat.price)
      end
    end

              # A luo cat jos tarvii
          # B Luo trans type jos tarvii
          # C linkitä noi jos tarvii

          # D transalations mukanan
          # E Community id mukana
          # F parent_id uuteen id:hen
    
  end

  def get_new_type_based_on_old(old_share_type)
    # TODO
    
  end
end
