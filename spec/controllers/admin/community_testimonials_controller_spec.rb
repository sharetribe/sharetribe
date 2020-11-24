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
                                     grade: 0,
                                     text: 'Hi from author')
    FactoryGirl.create(:testimonial, tx: transaction,
                                     author: person2,
                                     receiver: listing1.author,
                                     grade: 0,
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

      get :index, params: {community_id: community.id, status: 'published'}
      service = assigns(:service)
      expect(service.transactions.count).to eq 2
      expect(service.testimonials[:all_count]).to eq 4

      get :index, params: {community_id: community.id, status: 'positive'}
      service = assigns(:service)
      expect(service.transactions.count).to eq 1
      expect(service.testimonials[:all_count]).to eq 2

      get :index, params: {community_id: community.id, status: 'negative'}
      service = assigns(:service)
      expect(service.transactions.count).to eq 1
      expect(service.testimonials[:all_count]).to eq 2

      get :index, params: {community_id: community.id, status: 'skipped'}
      service = assigns(:service)
      expect(service.transactions.count).to eq 0
      expect(service.testimonials[:all_count]).to eq 0

      get :index, params: {community_id: community.id, status: 'waiting'}
      service = assigns(:service)
      expect(service.transactions.count).to eq 1
      expect(service.testimonials[:all_count]).to eq 0

      get :index, params: {community_id: community.id, status: 'blocked'}
      service = assigns(:service)
      expect(service.transactions.count).to eq 0
      expect(service.testimonials[:all_count]).to eq 0

      get :index, params: {community_id: community.id, status: ['published', 'waiting'] }
      service = assigns(:service)
      expect(service.transactions.count).to eq 3
      expect(service.testimonials[:all_count]).to eq 4
    end
  end

  describe "#unskip" do
    let(:tx) do
      FactoryGirl.create(:transaction, community: community,
                                       listing: listing1,
                                       starter: person3,
                                       starter_skipped_feedback: true,
                                       author_skipped_feedback: true,
                                       current_state: 'confirmed')
    end

    it 'unskips skipped testimonial' do
      expect(tx.starter_skipped_feedback).to eq true
      expect(tx.author_skipped_feedback).to eq true
      post :unskip, params: {format: :js, community_id: community.id, transaction_id: tx.id, from_tx_author: false}
      tx.reload
      expect(tx.starter_skipped_feedback).to eq false
      expect(tx.author_skipped_feedback).to eq true
      post :unskip, params: {format: :js, community_id: community.id, transaction_id: tx.id, from_tx_author: true}
      tx.reload
      expect(tx.starter_skipped_feedback).to eq false
      expect(tx.author_skipped_feedback).to eq false
    end
  end
end
