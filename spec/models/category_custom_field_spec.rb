require 'spec_helper'

describe CategoryCustomField do

  before(:each) do
    @category = FactoryGirl.create(:category, :name => "tools-and-hammers")
    @custom_field = FactoryGirl.create(:custom_field)

    @category.custom_fields.count.should == 0
    @custom_field.categories.count.should == 0
    
    @category_custom_field = FactoryGirl.create(:category_custom_field,
      :category => @category, :custom_field => @custom_field)

  end

  it "belongs to categories" do
    @category = Category.find(@category.id)
    @category.custom_fields.count.should == 1
  end

  it "belongs to custom fields" do
    @custom_field = CustomField.find(@custom_field.id)
    @custom_field.categories.count.should == 1
  end

end
