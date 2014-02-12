# encoding: UTF-8

require 'spec_helper'

include CategoriesHelper

describe CategoriesHelper do
  
  before (:each) do
    Rails.cache.clear
  end
  
  describe "#load_categories_and_transaction_types_to_db" do

    it "loads categorization to db based on given params" do
      transaction_types = {Sell: {en: {name: "Sellings"}}, Give: {en: {name: "Giving away"}}}
      categories = [
        {
        "item" => [
          "tools",
          "books"
          ]
        },
        "favor",
        "housing" 
      ]

      community = FactoryGirl.create(:community)
      CategoriesHelper.load_categories_and_transaction_types_to_db(community, transaction_types, categories)
      community.main_categories.count.should == 3
      community.categories.count.should == 5
      community.transaction_types.count.should == 2
    end
  end
end