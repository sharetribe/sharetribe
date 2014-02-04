describe Category do

  before(:each) do
    @category = FactoryGirl.create(:category, :community => @community)
    @category2 = FactoryGirl.create(:category, :community => @community)
    @subcategory = FactoryGirl.create(:category)
    @subcategory.update_attribute(:parent_id, @category.id)

    @custom_field = FactoryGirl.create(:custom_field, :categories => [@category])
    @subcustom_field = FactoryGirl.create(:custom_field, :categories => [@subcategory])

    @category.reload
    @subcategory.reload
  end

  describe "#move_custom_fields" do

    it "removing moves custom fields to new category" do
      @category2.custom_fields.should_not include(@custom_field)
      
      move_custom_fields(@category, @category2)
      
      @category2.custom_fields.should include(@custom_field)
    end

    it "removing moves custom fields from subcategories to new category" do
      @category2.custom_fields.should_not include(@custom_field)
      @category2.custom_fields.should_not include(@subcustom_field)

      move_custom_fields(@category, @category2)

      @category2.custom_fields.should include(@custom_field)
      @category2.custom_fields.should include(@subcustom_field)
    end

    it "moving custom fields does not create duplicates" do
      @custom_field.categories << @category2

      @category2.custom_fields.should include(@custom_field)
      @category2.custom_fields.should_not include(@subcustom_field)

      move_custom_fields(@category, @category2)
      @category2.custom_fields.should include(@custom_field)
      @category2.custom_fields.should include(@subcustom_field)
    end
  end
end