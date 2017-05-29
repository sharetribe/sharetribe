require 'spec_helper'

describe Admin::CategoriesController, type: :controller do
  before(:each) do
    @community = FactoryGirl.create(:community)

    @cat1 = FactoryGirl.create(:category, sort_priority: 1, community: @community)
    @cat2 = FactoryGirl.create(:category, sort_priority: 2, community: @community)
    @cat3 = FactoryGirl.create(:category, sort_priority: 3, community: @community)

    @request.host = "#{@community.ident}.lvh.me"
    @request.env[:current_marketplace] = @community

    @user = create_admin_for(@community)
    sign_in_for_spec(@user)
  end

  describe "#order" do
    it "responds with 200 ok" do
      post :order, params: { order: [@cat1.id, @cat2.id, @cat3.id].shuffle }
      expect(response).to be_success
    end

    it "reorders the categories" do
      new_order = [@cat3.id, @cat1.id, @cat2.id]
      post :order, params: { order: new_order }
      expect(@community.categories.pluck(:id)).to eq new_order
    end

    it "does not allow updates to other communities' categories" do
      community_other = FactoryGirl.create(:community)
      cat_other_community = FactoryGirl.create(:category, sort_priority: 3, community: community_other)

      new_order = [cat_other_community.id]
      post :order, params: { order: new_order }

      cat_other_community.reload
      expect(cat_other_community.sort_priority).to eq 3
    end
  end
end
