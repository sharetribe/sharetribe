# encoding: UTF-8

require 'spec_helper'

include CategoriesHelper

describe CategoriesHelper do
  
  before (:each) do
    Rails.cache.clear
  end
  
  describe "#load_categories_and_share_types_to_db" do

    it "loads categorization to db based on given params" do
      
      categories = [
        {
        "wood_based_materials" => [
                "wooden_disk",
                "wooden_board",
                "wood_shavings",
                "misc_wood"
          ]
        },
        {
        "plastic_and_rubber" => [
                "plastic_disk",
                "plastic_membranes",
                "misc_plastic"
          ]
        },
        {
        "metal" => [
                "iron_and_steel",
                "aluminium",
                "copper",
                "other_metal"
          ]
        },
        "concrete_and_brick",
        "glass_and_porcelain",
        "textile_and_leather",
        "soil_materials",
        "liquid_materials",
        "manufacturing_error_materials",
        "misc_material"
      ]

      top_categories = ["wood_based_materials",
      "plastic_and_rubber" ,
      "metal",
      "concrete_and_brick",
      "glass_and_porcelain",
      "textile_and_leather",
      "soil_materials",
      "liquid_materials",
      "manufacturing_error_materials",
      "misc_material"
      ]

      custom_translations = {
        "fi" => {
          "wood_based_materials" => "Puu, paperi ja kartonki",
          "wooden_disk" => "Levyt",
          "wooden_board" => "Lauta",
          "wood_shavings" => "Purut, lastut",
          "misc_wood" => "Sekalaiset",
          "plastic_and_rubber" => "Muovi ja kumi",
          "plastic_disk" => "Levyt",
          "plastic_membranes" => "Kalvot",
          "misc_plastic" => "Sekalaiset",
          "metal" => "Metallit",
          "iron_and_steel" => "Rauta, teräs",
          "aluminium" => "Alumiini",
          "copper" => "Kupari",
          "other_metal" => "Muut",
          "concrete_and_brick" => "Betoni ja tiili",
          "glass_and_porcelain" => "Lasi ja posliini",
          "textile_and_leather" => "Tekstiilit ja nahka",
          "soil_materials" => "Maa-ainekset, kivi ja tuhka",
          "liquid_materials" => "Nestemäiset ja lietteet",
          "manufacturing_error_materials" => "Valmistusvirhe-erät",
          "misc_material" => "Sekalaista"
        }
      }

      share_types = {
        "offer" => {:categories => top_categories},
          "sell" => {:parent => "offer", :categories => top_categories},
          "give_away" => {:parent => "offer", :categories => top_categories},
        "request" => {:categories => top_categories},
          "buy" => {:parent => "request", :categories => top_categories},
          "receive" => {:parent => "request", :categories => top_categories}, 
      }
      
      community = FactoryGirl.create(:community)
      CategoriesHelper.load_categories_and_share_types_to_db(:community_id => community.id, :categories => categories, :share_types => share_types)
      #puts community.categories.collect(&:name)
      #puts community.main_categories.collect(&:name)
      #puts community.share_types.collect(&:name)
      community.main_categories.count.should == 10
      community.categories.count.should == 21
      reset_categories_to_default
    end

    
  end
  
  describe "#load_default_categories_to_db" do
    it "should load default categories" do
      CategoriesHelper.load_default_categories_to_db
      Category.count.should == 19
      ShareType.count.should == 14
      community = FactoryGirl.create(:community)
      community.main_categories.count.should == 4
      community.listing_types.count.should == 2
      CommunityCategory.find_by_category_id_and_share_type_id_and_community_id(Category.find_by_name("housing").id, ShareType.find_by_name("rent_out").id, nil).price_quantity_placeholder.should == "long_time"
      CommunityCategory.find_by_category_id_and_share_type_id_and_community_id(Category.find_by_name("item").id, ShareType.find_by_name("sell").id, nil).price.should be_true
      
    end
    
  end
  
end