require 'spec_helper'

describe Admin::CommunityTransactionsController, type: :controller do
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
    FactoryGirl.create(:transaction,
                       community: community,
                       listing: listing1,
                       starter: person3,
                       current_state: nil,
                       last_transition_at: nil)
  end
  let(:admin) { create_admin_for(community) }

  before(:each) do
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    sign_in_for_spec(admin)
  end

  describe '#index' do

    before(:each) do
      transaction1
      transaction2
      transaction3
      transaction4
    end

    it 'works' do
      get :index, params: {community_id: community.id}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
    end

    it 'filters by party or listing title' do
      get :index, params: {community_id: community.id, q: 'Florence'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      get :index, params: {community_id: community.id, q: 'Sky cat'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 2
      expect(transactions.include?(transaction1)).to eq true
      expect(transactions.include?(transaction2)).to eq true
      get :index, params: {community_id: community.id, q: 'Apple cake'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 2
      expect(transactions.include?(transaction1)).to eq true
      expect(transactions.include?(transaction3)).to eq true
    end

    it 'filters by status' do
      get :index, params: {community_id: community.id, status: 'confirmed'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 1
      expect(transactions.include?(transaction1)).to eq true
    end

    it 'sort' do
      get :index, params: {community_id: community.id}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      expect(transactions[0]).to eq transaction1
      expect(transactions[1]).to eq transaction3
      expect(transactions[2]).to eq transaction2
      get :index, params: {community_id: community.id, direction: 'asc'}
      service = assigns(:service)
      transactions = service.transactions
      expect(transactions.count).to eq 3
      expect(transactions[0]).to eq transaction2
      expect(transactions[1]).to eq transaction3
      expect(transactions[2]).to eq transaction1
    end
  end

  describe '#confirm #cancel'  do
    let(:paid_transaction) do
      conversation = FactoryGirl.create(:conversation, community: community)
      conversation.participants << listing2.author
      conversation.participants << person2
      transaction = FactoryGirl.create(:transaction, community: community,
                                                     listing: listing2,
                                                     starter: person2,
                                                     current_state: 'paid',
                                                     payment_process: 'preauthorize',
                                                     conversation: conversation
                                      )
      FactoryGirl.create(:transaction_transition, to_state: "paid", transaction_id: transaction.id, most_recent: true)
      transaction.reload
      transaction
    end

    before(:each) do
      paid_transaction
    end

    it 'confirms transaction' do
      get :confirm, params: {community_id: community.id, id: paid_transaction.id}
      paid_transaction.reload
      expect(paid_transaction.current_state).to eq 'confirmed'
      last_transition = paid_transaction.transaction_transitions.last
      expect(last_transition.metadata['user_id']).to eq admin.id
      expect(last_transition.metadata['executed_by_admin']).to eq true
    end

    it 'cancels transaction' do
      get :cancel, params: {community_id: community.id, id: paid_transaction.id}
      paid_transaction.reload
      expect(paid_transaction.current_state).to eq 'disputed'
      last_transition = paid_transaction.transaction_transitions.last
      expect(last_transition.metadata['user_id']).to eq admin.id
      expect(last_transition.metadata['executed_by_admin']).to eq true
    end
  end

  describe 'canceled fow' do
    let(:buyer) { FactoryGirl.create(:person, member_of: community) }
    let(:seller) do
      FactoryGirl.create(:person, member_of: community,
                                  given_name: 'Sherry',
                                  family_name: 'Rivera',
                                  display_name: 'Sky caterpillar'
                        )
    end
    let(:listing) do
      FactoryGirl.create(:listing, community_id: community.id,
                                   title: 'Apple cake',
                                   author: seller)
    end
    let(:transaction) do
      FactoryGirl.create(:transaction_process, community_id: community.id)
      conversation = FactoryGirl.create(:conversation, community: community, last_message_at: 20.minutes.ago)
      tx = FactoryGirl.create(:transaction, community: community,
                                            listing: listing,
                                            starter: buyer,
                                            current_state: 'disputed',
                                            last_transition_at: 1.minute.ago,
                                            payment_process: :preauthorize,
                                            payment_gateway: :stripe,
                                            conversation: conversation
                             )
      FactoryGirl.create(:transaction_transition, to_state: 'disputed', tx: tx)
      FactoryGirl.create(:stripe_payment, community_id: community.id, transaction_id: tx.id)
      tx
    end

    #
    # Refund action send emails to seler, buyer
    #
    it 'refund' do
      get :refund, params: {community_id: community.id, id: transaction.id}

      transaction.reload
      expect(transaction.current_state).to eq 'refunded'

      ActionMailer::Base.deliveries = []
      process_jobs

      email_to_seller = ActionMailer::Base.deliveries[0]
      expect(email_to_seller.to.include?(seller.confirmed_notification_emails_to)).to eq true
      expect(email_to_seller.subject).to eq 'Order marked as refunded - The Sharetribe team has approved the dispute from Proto T'

      email_to_buyer = ActionMailer::Base.deliveries[1]
      expect(email_to_buyer.to.include?(buyer.confirmed_notification_emails_to)).to eq true
      expect(email_to_buyer.subject).to eq 'Order marked as refunded - The Sharetribe team has approved the dispute from Proto T'
    end

    it 'dissmis the cancelation' do
      get :dismiss, params: {community_id: community.id, id: transaction.id}

      transaction.reload
      expect(transaction.current_state).to eq 'dismissed'

      ActionMailer::Base.deliveries = []
      process_jobs

      email_to_seller = ActionMailer::Base.deliveries[0]
      expect(email_to_seller.to.include?(seller.confirmed_notification_emails_to)).to eq true
      expect(email_to_seller.subject).to eq 'Order dispute dismissed - The Sharetribe team has rejected the dispute from Proto T'

      email_to_buyer = ActionMailer::Base.deliveries[1]
      expect(email_to_buyer.to.include?(buyer.confirmed_notification_emails_to)).to eq true
      expect(email_to_buyer.subject).to eq 'Order dispute dismissed - The Sharetribe team has rejected the dispute from Proto T'

      expect(Delayed::Job.count).to eq 3
      handlers = Delayed::Job.all.map(&:handler)
      expect(handlers.select{|x| x.match 'TestimonialReminderJob'}.size).to eq 2
      expect(handlers.select{|x| x.match 'StripePayoutJob'}.size).to eq 1
    end
  end
end
