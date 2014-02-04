describe Admin::CategoryService do

  before(:each) do
    @category = FactoryGirl.create(:category, :community => @community)
    @category2 = FactoryGirl.create(:category, :community => @community)
    @subcategory = FactoryGirl.create(:category)
    @subcategory.update_attribute(:parent_id, @category.id)

    @custom_field = FactoryGirl.create(:custom_field, :categories => [@category])
    @subcustom_field = FactoryGirl.create(:custom_field, :categories => [@subcategory])

    @category.reload
    @subcategory.reload

    @category.custom_fields.count.should == 1
    @subcategory.custom_fields.count.should == 1
  end

  def include_by_id?(xs, model)
    xs.find { |x| x.id == model.id }
  end

  describe "#move_custom_fields" do

    it "removing moves custom fields to new category" do
      include_by_id?(@category2.custom_fields, @custom_field).should be_false

      Admin::CategoryService.move_custom_fields!(@category, @category2)
      @category2.reload

      include_by_id?(@category2.custom_fields, @custom_field).should be_true
    end

    it "removing moves custom fields from subcategories to new category" do
      include_by_id?(@category2.custom_fields, @custom_field).should be_false
      include_by_id?(@category2.custom_fields, @subcustom_field).should be_false

      Admin::CategoryService.move_custom_fields!(@category, @category2)
      @category2.reload

      include_by_id?(@category2.custom_fields, @custom_field).should be_true
      include_by_id?(@category2.custom_fields, @subcustom_field).should be_true
    end

    it "moving custom fields does not create duplicates" do
      @custom_field.categories << @category2

      include_by_id?(@category2.custom_fields, @custom_field).should be_true
      include_by_id?(@category2.custom_fields, @subcustom_field).should_not be_true
      @category2.custom_fields.count.should == 1

      Admin::CategoryService.move_custom_fields!(@category, @category2)
      @category2.reload

      include_by_id?(@category2.custom_fields, @custom_field).should be_true
      include_by_id?(@category2.custom_fields, @subcustom_field).should be_true
      @category2.custom_fields.count.should == 2
    end
  end
end