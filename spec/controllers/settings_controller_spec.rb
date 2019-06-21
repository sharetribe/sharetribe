require 'spec_helper'

describe SettingsController, type: :controller do

  describe "#unsubscribe" do
    before(:each) do
      @community = FactoryGirl.create(:community)
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
      @person = FactoryGirl.create(:person)

      FactoryGirl.create(:community_membership, :person => @person, :community => @community)
    end

    it "should unsubscribe the user from the email specified in parameters" do
      sign_in_for_spec(@person)
      @person.set_default_preferences
      expect(@person.min_days_between_community_updates).to eq(1)

      get :unsubscribe, params: {:email_type => "community_updates", :person_id => @person.username}
      puts response.body
      expect(response.status).to eq(200)

      @person = Person.find(@person.id) # fetch again to refresh
      expect(@person.min_days_between_community_updates).to eq(100000)
    end

    it "should unsubscribe with auth token" do
      t = AuthToken.create_unsubscribe_token(person_id: @person.id).token
      @person.set_default_preferences
      expect(@person.min_days_between_community_updates).to eq(1)

      get :unsubscribe, params: {:email_type => "community_updates", :person_id => @person.username, :auth => t}
      expect(response.status).to eq(200)

      @person = Person.find(@person.id) # fetch again to refresh
      expect(@person.min_days_between_community_updates).to eq(100000)
    end

    it "should not unsubscribe if no token provided" do
      @person.set_default_preferences
      expect(@person.min_days_between_community_updates).to eq(1)

      get :unsubscribe, params: {:email_type => "community_updates", :person_id => @person.username} 
      expect(response.status).to eq(401)
      expect(@person.min_days_between_community_updates).to eq(1)
    end
  end

  describe "#listings" do

    before(:all) do
      @community = FactoryGirl.create(:community)

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

      @joe_listings = [
        @listing_joe1, @listing_joe2, @listing_joe3,
      ]
    end

    before(:each) do
      @request.host = "#{@community.ident}.lvh.me"
      @request.env[:current_marketplace] = @community
      sign_in_for_spec(@joe)
    end

    describe "#listings search" do
      it "retrieves all author's listings in no query given" do
        get :listings, params: {person_id: @joe.username}
        expect(assigns("presenter").listings.size).to eq 3
      end

      it "finds listings by title" do
        @joe_listings.each do |listing|
          get :listings, params: {person_id: @joe.username, q: listing.title}
          listings = assigns("presenter").listings
          expect(listings.size).to eq 1
          expect(listings).to eq [listing]
        end
      end

      it "finds listings by category title" do
        get :listings, params: {person_id: @joe.username, q: @category1.translations.first.name}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 3
        expect(listings.map(&:category_id).uniq).to eq [@category1.id]

        get :listings, params: {person_id: @joe.username, q: @category2.translations.first.name}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 0
      end
    end

    describe "#listings status filter" do
      it "retrieves all when status not present" do
        get :listings, params: {person_id: @joe.username, status: []}
        expect(assigns("presenter").listings.size).to eq 3

        get :listings, params: {person_id: @joe.username}
        expect(assigns("presenter").listings.size).to eq 3
      end

      it "filters open" do
        get :listings, params: {person_id: @joe.username, status: ["open"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 1
        expect(listings.sort_by(&:id)).to eq [@listing_joe1]
      end

      it "filters closed" do
        get :listings, params: {person_id: @joe.username, status: ["closed"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 1
        expect(listings.sort_by(&:id)).to eq [@listing_joe2]
      end

      it "filters expired" do
        get :listings, params: {person_id: @joe.username, status: ["expired"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 1
        expect(listings.sort_by(&:id)).to eq [@listing_joe3]
      end

      it "filters open + expired" do
        get :listings, params: {person_id: @joe.username, status: ["expired", "open"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 2
        expect(listings.sort_by(&:id)).to eq [@listing_joe1, @listing_joe3]
      end

      it "filters closed + expired" do
        get :listings, params: {person_id: @joe.username, status: ["expired", "closed"]}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 2
        expect(listings.sort_by(&:id)).to eq [@listing_joe2, @listing_joe3]
      end

      it "applies both filter and query" do
        get :listings, params: {person_id: @joe.username, status: ["expired", "open"], q: "won"}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 0

        get :listings, params: {person_id: @joe.username, status: ["expired", "open"], q: "p"}
        listings = assigns("presenter").listings
        expect(listings.size).to eq 1
        expect(listings).to eq [@listing_joe3]
      end
    end
  end
end
