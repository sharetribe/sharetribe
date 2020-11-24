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

  describe "#transactions" do
    let(:community) { FactoryGirl.create(:community) }
    let(:person1) do
      FactoryGirl.create(:person, member_of: community,
                                  given_name: 'Florence',
                                  family_name: 'Torres',
                                  display_name: 'Floryt'
                        )
    end
    let(:person2) do
      FactoryGirl.create(:person, member_of: community,
                                  given_name: 'Sherry',
                                  family_name: 'Rivera',
                                  display_name: 'Sky caterpillar'
                        )
    end
    let(:person3) do
      FactoryGirl.create(:person, member_of: community,
                                  given_name: 'Connie',
                                  family_name: 'Brooks',
                                  display_name: 'Candidate'
                        )
    end
    let(:listing1) do
      FactoryGirl.create(:listing, community_id: community.id,
                                   title: 'Apple cake',
                                   author: person1)
    end
    let(:listing2) do
      FactoryGirl.create(:listing, community_id: community.id,
                                   title: 'Cosmic scooter',
                                   author: person1)
    end
    let(:listing3) do
      FactoryGirl.create(:listing, community_id: community.id,
                                   title: 'Cosmic scooter',
                                   author: person2)
    end
    let(:transaction1) do
      FactoryGirl.create(:transaction, community: community,
                                       listing: listing1,
                                       starter: person2,
                                       current_state: 'confirmed',
                                       last_transition_at: 1.minute.ago)
    end
    let(:transaction2) do
      FactoryGirl.create(:transaction, community: community,
                                       listing: listing2,
                                       starter: person2,
                                       current_state: 'paid',
                                       last_transition_at: 30.minutes.ago)

    end
    let(:transaction3) do
      conversation = FactoryGirl.create(:conversation, community: community, last_message_at: 20.minutes.ago)
      FactoryGirl.create(:transaction, community: community,
                                       listing: listing1,
                                       starter: person3,
                                       current_state: 'rejected',
                                       last_transition_at: 60.minutes.ago,
                                       conversation: conversation)
    end
    let(:transaction4) do
      conversation = FactoryGirl.create(:conversation, community: community, last_message_at: 20.minutes.ago)
      FactoryGirl.create(:transaction, community: community,
                                       listing: listing3,
                                       starter: person3,
                                       current_state: 'rejected',
                                       last_transition_at: 60.minutes.ago,
                                       conversation: conversation)
    end


    before(:each) do
      @request.host = "#{community.ident}.lvh.me"
      @request.env[:current_marketplace] = community
      sign_in_for_spec(person1)
      transaction1
      transaction2
      transaction3
      transaction4
    end

    it 'works' do
      get :transactions, params: {person_id: person1.username}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
    end

    it 'filters by party or listing title' do
      get :transactions, params: {person_id: person1.username, q: 'Florence'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      get :transactions, params: {person_id: person1.username, q: 'Sky cat'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 2
      expect(transactions.include?(transaction1)).to eq true
      expect(transactions.include?(transaction2)).to eq true
      get :transactions, params: {person_id: person1.username, q: 'Apple cake'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 2
      expect(transactions.include?(transaction1)).to eq true
      expect(transactions.include?(transaction3)).to eq true
    end

    it 'filters by status' do
      get :transactions, params: {person_id: person1.username, status: 'confirmed'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 1
      expect(transactions.include?(transaction1)).to eq true
    end

    it 'sort' do
      get :transactions, params: {person_id: person1.username}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      expect(transactions[0]).to eq transaction1
      expect(transactions[1]).to eq transaction3
      expect(transactions[2]).to eq transaction2
      get :transactions, params: {person_id: person1.username, direction: 'asc'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      expect(transactions[0]).to eq transaction2
      expect(transactions[1]).to eq transaction3
      expect(transactions[2]).to eq transaction1
    end
  end
end
