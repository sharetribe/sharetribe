require 'spec_helper'

describe ConfirmConversationsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
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
                                          current_state: 'paid',
                                          last_transition_at: 1.minute.ago,
                                          payment_process: :preauthorize,
                                          payment_gateway: :stripe,
                                          conversation: conversation
                           )
    FactoryGirl.create(:transaction_transition, to_state: 'paid', tx: tx)
    tx
  end

  before(:each) do
    @request.env["devise.mapping"] = Devise.mappings[:person]
    @request.host = "#{community.ident}.lvh.me"
    @request.env[:current_marketplace] = community
    sign_in_for_spec(buyer)
  end

  describe '#confirm' do
    it 'confirms transaction' do
      get :confirmation, params: {transaction: {status: "confirmed"},
                                  give_feedback: "true", locale: "en",
                                  person_id: buyer.id,
                                  id: transaction.id}
      transaction.reload
      expect(transaction.current_state).to eq 'confirmed'
    end

    it 'cancels transaction' do
      get :confirmation, params: {transaction: {status: "canceled"},
                                  give_feedback: "true", locale: "en",
                                  person_id: buyer.id,
                                  id: transaction.id}
      transaction.reload
      expect(transaction.current_state).to eq 'disputed'
    end
  end

  describe '#confirm canceled flow' do
    let(:admin) { FactoryGirl.create(:person, member_of: community, member_is_admin: true) }

    before(:each) do
      admin
    end

    it 'cancels transaction' do
      get :confirmation, params: {transaction: {status: "canceled"},
                                  give_feedback: "true", locale: "en",
                                  person_id: buyer.id,
                                  id: transaction.id}
      transaction.reload
      expect(transaction.current_state).to eq 'disputed'

      ActionMailer::Base.deliveries = []
      process_jobs

      expect(ActionMailer::Base.deliveries.size).to eq 3

      email_to_seller = ActionMailer::Base.deliveries[0]
      expect(email_to_seller.to.include?(seller.confirmed_notification_emails_to)).to eq true
      expect(email_to_seller.subject).to eq 'Order disputed - The Sharetribe team is reviewing the situation'

      email_to_buyer = ActionMailer::Base.deliveries[1]
      expect(email_to_buyer.to.include?(buyer.confirmed_notification_emails_to)).to eq true
      expect(email_to_buyer.subject).to eq 'Order disputed - The Sharetribe team is reviewing the situation'

      email_to_admin = ActionMailer::Base.deliveries[2]
      expect(email_to_admin.to.include?(admin.confirmed_notification_emails_to)).to eq true
      expect(email_to_admin.subject).to eq 'A transaction was disputed, you must decide what happens next'
    end
  end
end
