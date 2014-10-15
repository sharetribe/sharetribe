require 'spec_helper'

describe Admin::CustomFieldsController do
  describe "#destroy" do
    def create_custom_field_for(community)
      custom_field_count = community.custom_fields.count
      community.custom_fields.count.should eql(0)
      custom_field = FactoryGirl.create(:custom_dropdown_field)
      community.categories << custom_field.category_custom_fields.first.category
      community.custom_fields << custom_field
      community.save!
      community.custom_fields.count.should eql(custom_field_count + 1)
      return custom_field
    end

    before(:each) do
      @community = FactoryGirl.create(:community)
      @another_community = FactoryGirl.create(:community)

      @request.host = "#{@community.domain}.lvh.me"

      @person = create_admin_for(@community)
      sign_in_for_spec(@person)
    end

    it "should be allowed to remove a field that belongs to current community" do
      @custom_field = create_custom_field_for(@community)

      @community.custom_fields.count.should eql(1)
      delete :destroy, id: @custom_field.id

      community = Community.find(@community.id)
      community.custom_fields.count.should eql(0)
      custom_field = CustomField.find_by_id(@custom_field.id)
      custom_field.should be_nil
    end

    it "should not allow removal of a field that doesn't belong to current community" do
      @custom_field = create_custom_field_for(@another_community)

      community_custom_field_count = @community.custom_fields.count
      another_custom_field_count = @another_community.custom_fields.count

      delete :destroy, id: @custom_field.id

      community = Community.find(@community.id)
      another_community = Community.find(@another_community.id)
      community.custom_fields.count.should eql(community_custom_field_count)
      another_community.custom_fields.count.should eql(another_custom_field_count)

      custom_field = CustomField.find_by_id(@custom_field.id)
      custom_field.should_not be_nil
    end
  end
end
