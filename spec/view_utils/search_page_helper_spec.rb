require 'spec_helper'

describe SearchPageHelper do

  describe "selected view type" do

    it "returns param view type if param is present and it is one of the view types, otherwise comm default" do
      types = ["map", "list", "grid"]
      expect(SearchPageHelper.selected_view_type("map", "list", "grid", types)).to eq("map")
      expect(SearchPageHelper.selected_view_type(nil, "list", "grid", types)).to eq("list")
      expect(SearchPageHelper.selected_view_type("", "list", "grid", types)).to eq("list")
      expect(SearchPageHelper.selected_view_type("not_existing_view_type", "list", "grid", types)).to eq("list")
    end

    it "defaults to app default, if comm default is incorrect" do
      types = ["map", "list", "grid"]
      expect(SearchPageHelper.selected_view_type("", "list", "grid", types)).to eq("list")
      expect(SearchPageHelper.selected_view_type("", nil, "grid", types)).to eq("grid")
      expect(SearchPageHelper.selected_view_type("", "", "grid", types)).to eq("grid")
      expect(SearchPageHelper.selected_view_type("", "not_existing_view_type", "grid", types)).to eq("grid")
    end

  end

  describe "custom field options for search" do

    it "returns ids in correct order" do
      @custom_field1 = FactoryGirl.create(:custom_dropdown_field)
      @custom_field2 = FactoryGirl.create(:custom_dropdown_field)
      @custom_field_option1 = FactoryGirl.create(:custom_field_option, :custom_field =>  @custom_field1)
      @custom_field_option2 = FactoryGirl.create(:custom_field_option, :custom_field =>  @custom_field1)
      @custom_field_option3 = FactoryGirl.create(:custom_field_option, :custom_field =>  @custom_field2)
      @custom_field_option4 = FactoryGirl.create(:custom_field_option, :custom_field =>  @custom_field2)

      array = SearchPageHelper.dropdown_field_options_for_search({
        "filter_option_#{@custom_field_option1.id}" => @custom_field_option1.id,
        "filter_option_#{@custom_field_option2.id}" => @custom_field_option2.id,
        "filter_option_#{@custom_field_option3.id}" => @custom_field_option3.id,
        "filter_option_#{@custom_field_option4.id}" => @custom_field_option4.id
      })

      expect(array).to eq([
        {id: @custom_field1.id, value: [@custom_field_option1.id, @custom_field_option2.id], type: :selection_group, operator: :or},
        {id: @custom_field2.id, value: [@custom_field_option3.id, @custom_field_option4.id], type: :selection_group, operator: :or},
      ])
    end
  end
end
