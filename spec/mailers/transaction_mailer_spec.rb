require 'spec_helper'

describe TransactionMailer, type: :mailer do

  describe 'Payment receipt' do
    let(:community) { FactoryGirl.create(:community) }
    let(:seller) {
      FactoryGirl.create(:person, member_of: community,
                                  given_name: "Joan", family_name: "Smith")
    }
    let(:buyer) { FactoryGirl.create(:person, member_of: community) }
    let(:listing) { FactoryGirl.create(:listing, community_id: community.id, author: seller) }
    let(:paypal_transaction) do
      transaction = FactoryGirl.create(:transaction, starter: buyer,
                                                     community: community, listing: listing,
                                                     current_state: 'paid', payment_gateway: 'paypal')
      FactoryGirl.create(:paypal_payment, community_id: community.id, transaction_id: transaction.id,
                                          payment_total_cents: 500, fee_total_cents: 150, payment_status: "completed",
                                          commission_total_cents: 0, commission_fee_total_cents: 0)
      service_name(transaction.community_id)
      transaction
    end
    let(:stripe_transaction) do
      transaction = FactoryGirl.create(:transaction, starter: buyer,
                                                     community: community, listing: listing,
                                                     current_state: 'paid', payment_gateway: 'stripe')
      FactoryGirl.create(:stripe_payment, community_id: community.id, tx: transaction)
      service_name(transaction.community_id)
      transaction
    end

    describe '#payment_receipt_to_seller' do
      it 'works with default payment gateway' do
        email = TransactionMailer.payment_receipt_to_seller(paypal_transaction)
        expect(email.body).to have_text('You have been paid €5 for Sledgehammer by Proto. Here is your receipt.')
      end

      it 'works with stripe payment gateway' do
        email = TransactionMailer.payment_receipt_to_seller(stripe_transaction)
        expect(email.body).to have_text('The amount of €2 has been paid for Sledgehammer by Proto. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.')
      end
    end

    describe '#payment_receipt_to_buyer' do
      it 'works with default payment gateway' do
        email = TransactionMailer.payment_receipt_to_buyer(paypal_transaction)
        expect(email.body).to have_text('You have paid €5 for Sledgehammer to Joan. Here is a receipt of the payment.')
      end

      it 'works with stripe payment gateway' do
        email = TransactionMailer.payment_receipt_to_buyer(stripe_transaction)
        expect(email.body).to have_text('You have paid €2 for Sledgehammer. The money is being held by Sharetribe and will be released to Joan once you mark the order as completed. Here is a receipt of the payment.')
      end
    end

    def service_name(community_id)
      ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
    end
  end
end
