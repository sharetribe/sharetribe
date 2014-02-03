require 'spec_helper'

describe Category do

  before(:each) do
    @community = FactoryGirl.create(:community)
    @category = FactoryGirl.create(:category, :community => @community)
    @subcategory = FactoryGirl.create(:category)
    @subcategory.update_attribute(:parent_id, @category.id)

    @community.reload
    @category.reload
    @subcategory.reload
  end

  it "has listings?" do
    @category.has_listings?.should be_false

    @listing = FactoryGirl.create(:listing, {category: @category})
    @category.reload

    @category.has_listings?.should be_true
  end

  it "can not be deleted if it's the only top level category" do
    Category.find(@category.id).should_not be_nil

    @category.destroy

    Category.find(@category.id).should_not be_nil
  end

  it "removes subcategories if parent is removed" do
    @category2 = FactoryGirl.create(:category, :community => @community)
    Category.find(@category.id).should_not be_nil
    Category.find(@subcategory.id).should_not be_nil

    @category.destroy

    Category.find(@category.id).should be_nil
    Category.find(@subcategory.id).should be_nil
  end

end
