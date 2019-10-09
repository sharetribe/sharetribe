require 'spec_helper'

describe HomepageController, type: :controller do
  render_views

  let(:plan) do
    {
      expired: false,
      features: {
        whitelabel: true,
        admin_email: true,
        footer: false
      },
      created_at: Time.zone.now,
      updated_at: Time.zone.now
    }
  end

  describe "title and description" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
      @request.env[:current_plan] = plan
      @user = create_admin_for(@community)
      @user.update(is_admin: true)
      sign_in_for_spec(@user)
    end

    describe "#index" do
      it "renders default title and description" do
        get :index
        expect(response.body).to match('<title>Sharetribe - Test slogan</title>')
        expect(response.body).to match("<meta content='Test description - Test slogan' name='description'>")
      end

      it "renders updated meta title and description" do
        @community.community_customizations.first.update(meta_title: "SEO Title", meta_description: "SEO Description")
        get :index
        expect(response.body).to match('<title>SEO Title</title>')
        expect(response.body).to match("<meta content='SEO Description' name='description'>")
      end

      it "renders updated meta title and description when search params are provided" do
        @community.community_customizations.first.update(search_meta_title: "Search results for {{keywords_searched}}", search_meta_description: "Search results for {{keywords_searched}} at {{location_searched}}")
        get :index, params: {q: 'books', lq: 'New York'}
        expect(response.body).to match('<title>Search results for books</title>')
        expect(response.body).to match("<meta content='Search results for books at New York' name='description'>")
      end

      it "renders updated meta title and description when search by category is used" do
        @community.community_customizations.first.update(category_meta_title: "Search results for {{category_name}}", category_meta_description: "Search results for category {{category_name}}")
        @category = FactoryGirl.create(:category, :community => @community)
        @category.translation_attributes = {en: {name: "Test Category"}}
        @category.save
        get :index, params: {category: @category.url}
        category_name = @category.display_name(I18n.locale)
        expect(response.body).to match("<title>Search results for #{category_name}</title>")
        expect(response.body).to match("<meta content='Search results for category #{category_name}' name='description'>")
      end
    end
  end

  describe '#index' do
    let(:community) { FactoryGirl.create(:community) }

    before(:each) do
      @request.env["devise.mapping"] = Devise.mappings[:person]
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
    end

    let(:listing) { FactoryGirl.create(:listing, community_id: community.id) }
    let(:pending_listing) do
      FactoryGirl.create(:listing, community_id: community.id,
                                   state: Listing::APPROVAL_PENDING)
    end

    it 'shows approved listing' do
      listing
      get :index
      listings = assigns(:listings)
      expect(listings.count).to eq 1
    end

    it 'does not show pending listing' do
      pending_listing
      get :index
      listings = assigns(:listings)
      expect(listings.count).to eq 0
    end
  end
end
