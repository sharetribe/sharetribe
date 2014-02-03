require 'spec_helper'

describe Category do

  before(:each) do
    @category = FactoryGirl.create(:category)
  end

  it "has listings?" do
    @category.has_listings?.should be_false

    @listing = FactoryGirl.create(:listing, {category: @category})
    @category.reload

    @category.has_listings?.should be_true
  end

end
