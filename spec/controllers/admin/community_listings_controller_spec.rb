require 'spec_helper'

describe Admin::CommunityListingsController, type: :controller do

  describe 'filtering' do
    before(:all) do
      @community = FactoryGirl.create(:community)
      @user = create_admin_for(@community)

      @category1 = FactoryGirl.create(:category, community: @community)
      @category1.translations << FactoryGirl.create(:category_translation, :name => "Music", :locale => "en", :category => @category1)

      @category2 = FactoryGirl.create(:category, community: @community)
      @category2.translations << FactoryGirl.create(:category_translation, :name => "Books", :locale => "en", :category => @category2)

      @joe = FactoryGirl.create(:person, given_name: 'Joe')
      @joe.accepted_community = @community

      @jack = FactoryGirl.create(:person, given_name: 'Jack')
      @jack.accepted_community = @community

      @listing_joe1 = FactoryGirl.create(:listing, community_id: @community.id, author: @joe, category_id: @category1.id, title: "classic")

      @listing_joe2 = FactoryGirl.create(:listing, community_id: @community.id, author: @joe, category_id: @category1.id, title: "rock")
      @listing_joe2.update(open: 0)

      @listing_joe3 = FactoryGirl.create(:listing, community_id: @community.id, author: @joe, category_id: @category1.id, title: "pop")
      @listing_joe3.valid_until = 100.days.ago
      @listing_joe3.save(validate: false)

      @listing_jack1 = FactoryGirl.create(:listing, community_id: @community.id, author: @jack, category_id: @category2.id, title: "bible")

      @listing_jack2 = FactoryGirl.create(:listing, community_id: @community.id, author: @jack, category_id: @category2.id, title: "encyclopedia")
      @listing_jack2.update(open: false)

      @listing_jack3 = FactoryGirl.create(:listing, community_id: @community.id, author: @jack, category_id: @category2.id, title: "wonderland")
      @listing_jack3.valid_until = 100.days.ago
      @listing_jack3.save(validate: false)

      @all_listings = [
        @listing_joe1, @listing_joe2, @listing_joe3,
        @listing_jack1, @listing_jack2, @listing_jack3,
      ]
    end

    before(:each) do
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
      sign_in_for_spec(@user)
    end

    describe "#index search" do
      it "retrieves all listings in no query given" do
        get :index, params: {community_id: @community.id}
        expect(assigns("presenter").listings.size).to eq 6
      end

      it "finds listings by title" do
        @all_listings.each do |listing|
          get :index, params: {community_id: @community.id, q: listing.title}
          listings = assigns("presenter").listings
          expect(listings.size).to eq 1
          expect(listings).to eq [listing]
        end
      end

      it "finds listings by category title" do
        [@category1, @category2].each do |category|
          get :index, params: {community_id: @community.id, q: category.translations.first.name}
          listings = assigns("presenter").listings
          expect(listings.size).to eq 3
          expect(listings.map(&:category_id).uniq).to eq [category.id]
        end
      end

      it "finds listings by author" do
        [@joe, @jack].each do |author|
          get :index, params: {community_id: @community.id, q: author.given_name}
          listings = assigns("presenter").listings
          expect(listings.size).to eq 3
          expect(listings.map(&:author_id).uniq).to eq [author.id]
        end
      end
    end

    describe "#index status filter" do
      it "retrieves all when status not present" do
        get :index, params: {community_id: @community.id, status: []}
        expect(assigns("presenter").listings.size).to eq 6

        get :index, params: {community_id: @community.id}
        expect(assigns("presenter").listings.size).to eq 6
      end

      it "filters open" do
        get :index, params: {community_id: @community.id, status: ["open"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 2
        expect(listings.sort_by(&:id)).to eq [@listing_joe1, @listing_jack1]
      end

      it "filters closed" do
        get :index, params: {community_id: @community.id, status: ["closed"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 2
        expect(listings.sort_by(&:id)).to eq [@listing_joe2, @listing_jack2]
      end

      it "filters expired" do
        get :index, params: {community_id: @community.id, status: ["expired"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 2
        expect(listings.sort_by(&:id)).to eq [@listing_joe3, @listing_jack3]
      end

      it "filters open + expired" do
        get :index, params: {community_id: @community.id, status: ["expired", "open"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 4
        expect(listings.sort_by(&:id)).to eq [@listing_joe1, @listing_joe3, @listing_jack1, @listing_jack3]
      end

      it "filters closed + expired" do
        get :index, params: {community_id: @community.id, status: ["expired", "closed"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 4
        expect(listings.sort_by(&:id)).to eq [@listing_joe2, @listing_joe3, @listing_jack2, @listing_jack3]
      end

      it "applies both filter and query" do
        get :index, params: {community_id: @community.id, status: ["expired", "open"], q: "won"}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 1
        expect(listings).to eq [@listing_jack3]

        get :index, params: {community_id: @community.id, status: ["expired", "open"], q: "p"}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 1
        expect(listings).to eq [@listing_joe3]
      end
    end
  end

  describe 'approval' do
    let(:community) { FactoryGirl.create(:community) }
    let(:listing) {
      FactoryGirl.create(:listing, community_id: community.id,
                                   state: Listing::APPROVAL_PENDING)
    }
    let(:follower_of_listing_author) do
      person = FactoryGirl.create(:person, member_of: community)
      listing.author.followers << person
      person
    end

    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      sign_in_for_spec(create_admin_for(community))
    end

    describe '#approve' do
      it 'approves listing' do
        post :update, params: {community_id: community.id, id: listing.id,
                               listing: {state: Listing::APPROVED}},
                      format: :js
        listing.reload
        expect(listing.state).to eq Listing::APPROVED
      end

      it 'One email to the listing author immediately
        when an admin has approved the listing' do
        stub_thinking_sphinx
        ActionMailer::Base.deliveries = []
        get :approve, params: {community_id: community.id, id: listing.id},
                      format: :js
        listing.reload
        expect(listing.state).to eq Listing::APPROVED
        expect(listing.approval_count).to eq 1

        process_jobs
        expect(ActionMailer::Base.deliveries).not_to be_empty
        email = ActionMailer::Base.deliveries.first
        expect(email.to.include?(listing.author.confirmed_notification_emails_to)).to eq true
        expect(email.subject).to eq 'The Sharetribe team has approved your listing "Sledgehammer"'
      end

      it 'notifies followers only once, when the listing is approved for the first time' do
        follower_of_listing_author
        ActionMailer::Base.deliveries = []
        get :approve, params: {community_id: community.id, id: listing.id},
                      format: :js
        listing.reload
        expect(listing.approval_count).to eq 1

        process_jobs
        expect(ActionMailer::Base.deliveries).not_to be_empty
        email = ActionMailer::Base.deliveries.last
        expect(email.to.include?(follower_of_listing_author.confirmed_notification_emails_to)).to eq true
        expect(email.subject).to eq 'Proto T has posted a new listing in Sharetribe'

        listing.state = Listing::APPROVAL_PENDING
        listing.save

        ActionMailer::Base.deliveries = []
        get :approve, params: {community_id: community.id, id: listing.id},
                      format: :js
        listing.reload
        expect(listing.approval_count).to eq 2

        process_jobs
        expect(ActionMailer::Base.deliveries).not_to be_empty
        email = ActionMailer::Base.deliveries.last
        expect(email.to.include?(follower_of_listing_author.confirmed_notification_emails_to)).to eq false
      end
    end

    it '#reject. One email to the listing author immediately
      when an admin has rejected the listing' do
      stub_thinking_sphinx
      ActionMailer::Base.deliveries = []
      get :reject, params: {community_id: community.id, id: listing.id},
                   format: :js
      listing.reload
      expect(listing.state).to eq Listing::APPROVAL_REJECTED

      process_jobs
      expect(ActionMailer::Base.deliveries).not_to be_empty
      email = ActionMailer::Base.deliveries.first
      expect(email.to.include?(listing.author.confirmed_notification_emails_to)).to eq true
      expect(email.subject).to eq 'The Sharetribe team has rejected your listing "Sledgehammer"'
    end
  end
end
