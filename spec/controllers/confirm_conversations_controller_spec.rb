require 'spec_helper'

describe ConfirmConversationsController, type: :controller do
  let(:community) { FactoryGirl.create(:community) }
  let(:person) { FactoryGirl.create(:person, member_of: community) }
  let(:person2) do
    FactoryGirl.create(:person, member_of: community,
                                given_name: 'Sherry',
                                family_name: 'Rivera',
                                display_name: 'Sky caterpillar'
                      )
  end
  let(:listing) do
    FactoryGirl.create(:listing, community_id: community.id,
                                 title: 'Apple cake',
                                 author: person2)
  end
  let(:transaction) do
    FactoryGirl.create(:transaction_process, community_id: community.id)
    conversation = FactoryGirl.create(:conversation, community: community, last_message_at: 20.minutes.ago)
    tx = FactoryGirl.create(:transaction, community: community,
                                          listing: listing,
                                          starter: person,
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
    sign_in_for_spec(person)
  end

  describe '#confirm' do
    it 'confirms transaction' do
      get :confirmation, params: {transaction: {status: "confirmed"},
                                  give_feedback: "true", locale: "en",
                                  person_id: person.id,
                                  id: transaction.id}
      transaction.reload
      expect(transaction.current_state).to eq 'confirmed'
    end

    it 'cancels transaction' do
      get :confirmation, params: {transaction: {status: "canceled"},
                                  give_feedback: "true", locale: "en",
                                  person_id: person.id,
                                  id: transaction.id}
      transaction.reload
      expect(transaction.current_state).to eq 'canceled'
    end
  end
end
