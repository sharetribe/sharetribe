require 'spec_helper'

describe Admin::CustomFieldsController do
  describe "#destroy" do
    def create_admin_for(community)
      person = FactoryGirl.create(:person)
      members_count = community.community_memberships.count
      admins_length = community.admins.length
      community.members << person
      membership = CommunityMembership.find_by_community_id_and_person_id(community.id, person.id)
      membership.admin = true
      membership.save
      community.members.count.should eql(members_count + 1)
      community.admins.length.should eql(admins_length + 1)
      return person
    end

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
      @community = FactoryGirl.create(:community, :custom_fields_allowed => true)
      @another_community = FactoryGirl.create(:community, :custom_fields_allowed => true)

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
