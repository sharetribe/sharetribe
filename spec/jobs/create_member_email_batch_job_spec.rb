require "spec_helper"

RSpec.describe CreateMemberEmailBatchJob, type: :job do
  let(:community) { FactoryGirl.create(:community) }
  let(:transaction_process) { FactoryGirl.create(:transaction_process) }
  let(:person_with_listing_with_payments) do
    person = FactoryGirl.create(:person, member_of: community)
    paypal_account = FactoryGirl.create(:paypal_account, person_id: person.id, community_id: community.id)
    FactoryGirl.create(:order_permission, paypal_account: paypal_account)
    FactoryGirl.create(:billing_agreement, paypal_account: paypal_account)
    FactoryGirl.create(:stripe_account, person_id: person.id, community_id: community.id, stripe_seller_id: 'ABC')
    person
  end
  let(:person_with_paypal_no_listing) do
    person = FactoryGirl.create(:person, member_of: community)
    paypal_account = FactoryGirl.create(:paypal_account, person_id: person.id, community_id: community.id)
    FactoryGirl.create(:order_permission, paypal_account: paypal_account)
    FactoryGirl.create(:billing_agreement, paypal_account: paypal_account)
    person
  end
  let(:person_with_stripe_no_listing) do
    person = FactoryGirl.create(:person, member_of: community)
    FactoryGirl.create(:stripe_account, person_id: person.id, community_id: community.id, stripe_seller_id: 'ABC')
    person
  end
  let(:person_with_listing_no_payments) { FactoryGirl.create(:person, member_of: community) }
  let(:person_no_listing_no_payments) { FactoryGirl.create(:person, member_of: community) }
  let(:person_started_transaction) { FactoryGirl.create(:person, member_of: community) }
  let(:person_posting_allowed) do
    person = FactoryGirl.create(:person, member_of: community)
    person.community_membership.update_column(:can_post_listings, true)
    person
  end
  let(:listing_with_payments) {
    FactoryGirl.create(:listing, community_id: community.id,
                                 listing_shape_id: 123,
                                 transaction_process_id: transaction_process.id,
                                 author: person_with_listing_with_payments)
  }
  let(:listing_no_payments) {
    FactoryGirl.create(:listing, community_id: community.id,
                                 listing_shape_id: 123,
                                 transaction_process_id: transaction_process.id,
                                 author: person_with_listing_no_payments)
  }
  let(:transaction) do
    FactoryGirl.create(:transaction, community: community,
                                     listing: listing_with_payments,
                                     starter: person_started_transaction,
                                     current_state: 'paid')
  end

  describe '#members' do
    before :each do
      transaction
      listing_no_payments
      person_no_listing_no_payments
      person_posting_allowed
      person_with_paypal_no_listing
      person_with_stripe_no_listing
    end

    it '#works' do
      members = CreateMemberEmailBatchJob.new.community_members('nonexisting', community)
      expect(members.count).to eq 0
      members = CreateMemberEmailBatchJob.new.community_members('all_users', community)
      expect(members.count).to eq 7
      members = CreateMemberEmailBatchJob.new.community_members('posting_allowed', community)
      expect(members.count).to eq 1
      expect(members.first).to eq person_posting_allowed
      members = CreateMemberEmailBatchJob.new.community_members('with_listing', community)
      expect(members.count).to eq 2
      expect(members.include?(person_with_listing_with_payments)).to eq true
      expect(members.include?(person_with_listing_no_payments)).to eq true
      members = CreateMemberEmailBatchJob.new.community_members('with_listing_no_payment', community)
      expect(members.count).to eq 1
      expect(members.first).to eq person_with_listing_no_payments
      members = CreateMemberEmailBatchJob.new.community_members('with_payment_no_listing', community)
      expect(members.count).to eq 2
      expect(members.include?(person_with_paypal_no_listing)).to eq true
      expect(members.include?(person_with_stripe_no_listing)).to eq true
      members = CreateMemberEmailBatchJob.new.community_members('no_listing_no_payment', community)
      expect(members.count).to eq 3
      expect(members.include?(person_no_listing_no_payments)).to eq true
      expect(members.include?(person_started_transaction)).to eq true
      expect(members.include?(person_posting_allowed)).to eq true
      members = CreateMemberEmailBatchJob.new.community_members('customers', community)
      expect(members.count).to eq 0 # disabled at the moment
    end
  end
end
