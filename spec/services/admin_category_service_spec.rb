require 'spec_helper'

describe Admin::CategoryService do

  before(:each) do
    @category = FactoryGirl.create(:category, :community => @community)
    @category2 = FactoryGirl.create(:category, :community => @community)
    @subcategory = FactoryGirl.create(:category)
    @subcategory.update_attribute(:parent_id, @category.id)
    @subcategory2 = FactoryGirl.create(:category)
    @subcategory2.update_attribute(:parent_id, @category.id)

    @custom_field = FactoryGirl.create(:custom_field, :categories => [@category])
    @subcustom_field = FactoryGirl.create(:custom_field, :categories => [@subcategory, @subcategory2])

    @category.reload
    @subcategory.reload
    @subcategory2.reload

    expect(@category.custom_fields.count).to eq(1)
    expect(@subcategory.custom_fields.count).to eq(1)
    expect(@subcategory2.custom_fields.count).to eq(1)
  end

  def include_by_id?(xs, model)
    xs.find { |x| x.id == model.id }
  end

  describe "#move_custom_fields" do

    it "removing moves custom fields to new category" do
      expect(include_by_id?(@category2.custom_fields, @custom_field)).to be_falsey

      Admin::CategoryService.move_custom_fields!(@category, @category2)
      @category2.reload

      expect(include_by_id?(@category2.custom_fields, @custom_field)).to be_truthy
    end

    it "removing moves custom fields from subcategories to new category" do
      expect(include_by_id?(@category2.custom_fields, @custom_field)).to be_falsey
      expect(include_by_id?(@category2.custom_fields, @subcustom_field)).to be_falsey

      Admin::CategoryService.move_custom_fields!(@category, @category2)
      @category2.reload

      expect(include_by_id?(@category2.custom_fields, @custom_field)).to be_truthy
      expect(include_by_id?(@category2.custom_fields, @subcustom_field)).to be_truthy
    end

    it "moving custom fields does not create duplicates" do
      @custom_field.categories << @category2

      expect(include_by_id?(@category2.custom_fields, @custom_field)).to be_truthy
      expect(include_by_id?(@category2.custom_fields, @subcustom_field)).not_to be_truthy
      expect(@category2.custom_fields.count).to eq(1)

      Admin::CategoryService.move_custom_fields!(@category, @category2)
      @category2.reload

      expect(include_by_id?(@category2.custom_fields, @custom_field)).to be_truthy
      expect(include_by_id?(@category2.custom_fields, @subcustom_field)).to be_truthy
      expect(@category2.custom_fields.count).to eq(2)
    end
  end

  describe "#merge_targets_for" do

      def add_child(parent, child)
        parent.children << child
      end

      # Create following category structure:
      #
      # Category A
      # - Subcategory A1
      # Category B
      # Category C
      # - Subcategory C1
      # - Subcategory C2
      before(:each) do
        @a = FactoryGirl.create(:category)
        @a1 = FactoryGirl.create(:category)
        @b = FactoryGirl.create(:category)
        @c = FactoryGirl.create(:category)
        @c1 = FactoryGirl.create(:category)
        @c2 = FactoryGirl.create(:category)
        add_child(@a, @a1)
        add_child(@c, @c1)
        add_child(@c, @c2)

        @categories = [@a, @a1, @b, @c, @c1, @c2]
      end

      # Merge targets for:
      # A  => B, C1, C2
      # A1 => A, B, C1, C2
      # B  => A1, C1, C2
      # C  => A1, B
      # C1 => A1, B, C2
      # C2 => A1, B, C1
      it "finds possible merge targets for category to be removed" do
        def merge_targets_for(c)
          Admin::CategoryService.merge_targets_for(@categories, c)
        end

        expect(merge_targets_for(@a )).to eql([@b,  @c1, @c2])
        expect(merge_targets_for(@a1)).to eql([@a,  @b,  @c1, @c2])
        expect(merge_targets_for(@b )).to eql([@a1, @c1, @c2])
        expect(merge_targets_for(@c )).to eql([@a1, @b])
        expect(merge_targets_for(@c1)).to eql([@a1, @b, @c2])
        expect(merge_targets_for(@c2)).to eql([@a1, @b, @c1])
      end
  end
end
