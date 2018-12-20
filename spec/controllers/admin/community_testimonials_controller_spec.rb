require 'spec_helper'

describe Admin::CommunityTestimonialsController, type: :controller do
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
  let(:transaction1) do
    transaction = FactoryGirl.create(:transaction, community: community,
                                                   listing: listing1,
                                                   starter: person2,
                                                   current_state: 'confirmed')
    FactoryGirl.create(:testimonial, tx: transaction,
                                     author: listing1.author,
                                     receiver: person2,
                                     text: 'Hi from author')
    FactoryGirl.create(:testimonial, tx: transaction,
                                     author: person2,
                                     receiver: listing1.author,
                                     text: 'Hi from starter')
    transaction
  end
  let(:transaction2) do
    transaction = FactoryGirl.create(:transaction, community: community,
                                                   listing: listing2,
                                                   starter: person2,
                                                   current_state: 'confirmed')
    FactoryGirl.create(:testimonial, tx: transaction,
                                     author: listing2.author,
                                     receiver: person2,
                                     text: 'A heavy snowstorm')
    FactoryGirl.create(:testimonial, tx: transaction,
                                     author: person2,
                                     receiver: listing2.author,
                                     text: 'Almost 60 crashes were reported in Virginia')
    transaction
  end
  let(:transaction3) do
    transaction = FactoryGirl.create(:transaction, community: community,
                                                   listing: listing1,
                                                   starter: person3,
                                                   current_state: 'confirmed')
    transaction
  end

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    user = create_admin_for(community)
    sign_in_for_spec(user)
  end

  describe "#index" do
    it 'works' do
      transaction1
      transaction2
      transaction3
      get :index, params: {community_id: community.id}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      testimonials = service.testimonials
      expect(testimonials[:all_count]).to eq 4
    end

    it 'filters' do
      transaction1
      transaction2
      transaction3
      get :index, params: {community_id: community.id, q: 'Florence'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      testimonials = service.testimonials
      expect(testimonials[:all_count]).to eq 4
      get :index, params: {community_id: community.id, q: 'Rivera'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 2
      expect(transactions.include?(transaction1)).to eq true
      expect(transactions.include?(transaction2)).to eq true
      testimonials = service.testimonials
      expect(testimonials[:all_count]).to eq 4
      get :index, params: {community_id: community.id, q: 'caterpillar'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 2
      expect(transactions.include?(transaction1)).to eq true
      expect(transactions.include?(transaction2)).to eq true
      testimonials = service.testimonials
      expect(testimonials[:all_count]).to eq 4
      get :index, params: {community_id: community.id, q: 'cake'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 2
      expect(transactions.include?(transaction1)).to eq true
      expect(transactions.include?(transaction3)).to eq true
      testimonials = service.testimonials
      expect(testimonials[:all_count]).to eq 2
      get :index, params: {community_id: community.id, q: 'Hi from author'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 1
      expect(transactions.first).to eq transaction1
      testimonials = service.testimonials
      expect(testimonials[:all_count]).to eq 2
      get :index, params: {community_id: community.id, q: 'Connie'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 1
      expect(transactions.first).to eq transaction3
      testimonials = service.testimonials
      expect(testimonials[:all_count]).to eq 0
    end
  end
end
