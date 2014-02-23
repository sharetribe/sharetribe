class CommunityCategory < ActiveRecord::Base
  belongs_to :community
  belongs_to :category
  belongs_to :share_type
end

class ShareType < ActiveRecord::Base
    
  has_many :sub_share_types, :class_name => "ShareType", :foreign_key => "parent_id"
  # children is a more generic alias for sub share_types, used in classification.rb
  has_many :children, :class_name => "ShareType", :foreign_key => "parent_id"
  belongs_to :parent, :class_name => "ShareType"
  has_many :community_categories
  has_many :communities, :through => :community_categories
  has_many :listings
  has_many :translations, :class_name => "ShareTypeTranslation", :dependent => :destroy 

  
end

class FixPriceQuantityPlaceholders < ActiveRecord::Migration


  def up

    # handle default rentals
    Rent.find_each do |rental_tt|
      puts "Updating trans type #{rental_tt.class} at #{rental_tt.community.domain} to have placeholder time"
      rental_tt.update_column(:price_quantity_placeholder, "time")
    end  

    # handle custom cases
    CommunityCategory.where("price_quantity_placeholder IS NOT NULL").each do |cc|
      community = cc.community
      if community #handle custom cases
        share_type = cc.share_type
        transaction_type_class = SHARE_TYPE_MAP[share_type.name]

        transaction_type = transaction_type_class.find_by_community_id(community.id)
        puts "Updating trans type #{transaction_type.class} at #{community.domain} to have placeholder #{cc.price_quantity_placeholder}"
        transaction_type.update_column(:price_quantity_placeholder, cc.price_quantity_placeholder)
      end

    end  

  end

  def down
    raise  ActiveRecord::IrreversibleMigration, "Reverse migration not implemented\n"
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
end
