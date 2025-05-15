require 'spec_helper'

describe TransactionMailer, type: :mailer do

  describe 'Payment receipt' do
    let(:community) { FactoryBot.create(:community) }
    let(:seller) {
      FactoryBot.create(:person, member_of: community,
                                 given_name: "Joan", family_name: "Smith")
    }
    let(:buyer) { FactoryBot.create(:person, member_of: community) }
    let(:listing) do
      listing = FactoryBot.create(:listing, community_id: community.id, author: seller)
      listing.working_hours_new_set
      listing.save
      listing
    end
    let(:paypal_transaction) do
      transaction = FactoryBot.create(:transaction, starter: buyer,
                                                    community: community, listing: listing,
                                                    current_state: 'paid', payment_gateway: 'paypal',
                                                    unit_price_cents: 500,
                                                    unit_price_currency: "EUR")
      FactoryBot.create(:paypal_payment, community_id: community.id, transaction_id: transaction.id,
                                         payment_total_cents: 500, fee_total_cents: 150, payment_status: "completed",
                                         commission_total_cents: 0, commission_fee_total_cents: 0)
      service_name(transaction.community_id)
      transaction
    end
    let(:stripe_transaction) do
      transaction = FactoryBot.create(:transaction, starter: buyer,
                                                    community: community, listing: listing,
                                                    current_state: 'paid', payment_gateway: 'stripe',
                                                    unit_price_cents: 200,
                                                    unit_price_currency: "EUR")
      FactoryBot.create(:stripe_payment, community_id: community.id, tx: transaction,
                                         buyer_commission: 0)
      service_name(transaction.community_id)
      transaction
    end
    let(:paypal_transaction_per_hour) do
      transaction = FactoryBot.create(:transaction, starter: buyer,
                                                    community: community, listing: listing,
                                                    current_state: 'paid', payment_gateway: 'paypal',
                                                    unit_price_cents: 500,
                                                    unit_price_currency: "EUR",
                                                    listing_quantity: 3,
                                                    unit_type: 'hour')
      FactoryBot.create(:paypal_payment, community_id: community.id, transaction_id: transaction.id,
                                         payment_total_cents: 1500, fee_total_cents: 150, payment_status: "completed",
                                         commission_total_cents: 0, commission_fee_total_cents: 0)
      service_name(transaction.community_id)
      FactoryBot.create(:booking, tx: transaction, start_time: '2017-11-14 09:00',
                                  end_time: '2017-11-14 12:00', per_hour: true)
      transaction
    end
    let(:stripe_transaction_per_hour) do
      transaction = FactoryBot.create(:transaction, starter: buyer,
                                                    community: community, listing: listing,
                                                    current_state: 'paid', payment_gateway: 'stripe',
                                                    unit_price_cents: 200,
                                                    unit_price_currency: "EUR",
                                                    listing_quantity: 3,
                                                    unit_type: 'hour')
      FactoryBot.create(:stripe_payment, community_id: community.id, tx: transaction,
                                         sum_cents: 600,
                                         buyer_commission: 0)
      service_name(transaction.community_id)
      FactoryBot.create(:booking, tx: transaction, start_time: '2017-11-14 09:00',
                                  end_time: '2017-11-14 12:00', per_hour: true)
      transaction
    end
    let(:stripe_transaction_with_buyer_commission) do
      transaction = FactoryBot.create(:transaction, starter: buyer,
                                                    community: community, listing: listing,
                                                    current_state: 'paid', payment_gateway: 'stripe',
                                                    commission_from_seller: 12,
                                                    commission_from_buyer: 8)
      FactoryBot.create(:stripe_payment, community_id: community.id, tx: transaction,
                                         sum_cents: 11000,
                                         commission_cents: 1200,
                                         buyer_commission_cents: 800)
      service_name(transaction.community_id)
      transaction
    end
    let(:stripe_transaction_per_hour_with_shipping_with_buyer_commission) do
      transaction = FactoryBot.create(:transaction, starter: buyer,
                                                    community: community, listing: listing,
                                                    current_state: 'paid', payment_gateway: 'stripe',
                                                    unit_price_cents: 200,
                                                    unit_price_currency: "EUR",
                                                    listing_quantity: 3,
                                                    unit_type: 'hour',
                                                    shipping_price_cents: 300,
                                                    commission_from_buyer: 20)
      FactoryBot.create(:stripe_payment, community_id: community.id, tx: transaction,
                                         sum_cents: 1020,
                                         buyer_commission_cents: 120)
      service_name(transaction.community_id)
      FactoryBot.create(:booking, tx: transaction, start_time: '2017-11-14 09:00',
                                  end_time: '2017-11-14 12:00', per_hour: true)
      transaction
    end

    describe '#payment_receipt_to_seller' do
      it 'works with default payment gateway' do
        email = TransactionMailer.payment_receipt_to_seller(paypal_transaction)
        expect(email.body).to have_text('you have been paid €5 for Sledgehammer by Proto T. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text("Price Proto T paid: €5", normalize_ws: true)
        expect(email.body).to have_text('Sharetribe service fee: €0', normalize_ws: true)
        expect(email.body).to have_text('Payment processing fee: -€1.50', normalize_ws: true)
        expect(email.body).to have_text('Total: €3.50', normalize_ws: true)
      end

      it 'works with default payment gateway per hour' do
        email = TransactionMailer.payment_receipt_to_seller(paypal_transaction_per_hour)
        expect(email.body).to have_text('you have been paid €15 for Sledgehammer, per hour by Proto T. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text('Price per hour €5', normalize_ws: true)
        expect(email.body).to have_text('Duration 3', normalize_ws: true)
        expect(email.body).to have_text('Price Proto T paid: €15', normalize_ws: true)
        expect(email.body).to have_text('Sharetribe service fee: €0', normalize_ws: true)
        expect(email.body).to have_text('Payment processing fee: -€1.50', normalize_ws: true)
        expect(email.body).to have_text('Total: €13.50', normalize_ws: true)
      end

      it 'works with stripe payment gateway' do
        email = TransactionMailer.payment_receipt_to_seller(stripe_transaction)
        expect(email.body).to have_text('you have been paid €2 for Sledgehammer by Proto T. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text('Price Proto T paid: €2', normalize_ws: true)
        expect(email.body).to have_text('Sharetribe service fee: -€1', normalize_ws: true)
        expect(email.body).to have_text('Total: €1', normalize_ws: true)
      end

      it 'works with stripe payment gateway per hour' do
        email = TransactionMailer.payment_receipt_to_seller(stripe_transaction_per_hour)
        expect(email.body).to have_text('you have been paid €6 for Sledgehammer, per hour by Proto T. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text('Price per hour €2', normalize_ws: true)
        expect(email.body).to have_text('Duration 3', normalize_ws: true)
        expect(email.body).to have_text('Price Proto T paid: €6', normalize_ws: true)
        expect(email.body).to have_text('Sharetribe service fee: -€1', normalize_ws: true)
        expect(email.body).to have_text('Total: €5', normalize_ws: true)
      end

      describe 'without buyer commission' do
        it 'works with default payment gateway' do
          email = TransactionMailer.payment_receipt_to_seller(paypal_transaction)
          expect(email.body).to have_text('you have been paid €5 for Sledgehammer by Proto T. Here is your receipt.', normalize_ws: true)
        end

        it 'works with stripe payment gateway' do
          email = TransactionMailer.payment_receipt_to_seller(stripe_transaction)
          expect(email.body).to have_text('you have been paid €2 for Sledgehammer by Proto T. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
        end
      end

      describe 'with buyer commission' do
        it 'works with stripe payment gateway' do
          email = TransactionMailer.payment_receipt_to_seller(stripe_transaction_with_buyer_commission)
          expect(email.body).to have_text('you have been paid €102 for Sledgehammer by Proto T. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
          expect(email.body).to have_text('Subtotal: €102', normalize_ws: true)
          expect(email.body).to have_text('Sharetribe service fee: -€12', normalize_ws: true)
          expect(email.body).to have_text('Total: €90', normalize_ws: true)
        end

        it 'works with stripe payment gateway per hour with shipping' do
          email = TransactionMailer.payment_receipt_to_seller(stripe_transaction_per_hour_with_shipping_with_buyer_commission)
          expect(email.body).to have_text('you have been paid €9 for Sledgehammer, per hour by Proto T. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
          expect(email.body).to have_text('Price per hour €2', normalize_ws: true)
          expect(email.body).to have_text('Duration 3', normalize_ws: true)
          expect(email.body).to have_text('Subtotal: €6', normalize_ws: true)
          expect(email.body).to have_text('Sharetribe service fee: -€1', normalize_ws: true)
          expect(email.body).to have_text('Shipping: €3', normalize_ws: true)
          expect(email.body).to have_text('Total: €8', normalize_ws: true)
        end
      end
    end

    describe '#payment_receipt_to_buyer' do
      it 'works with default payment gateway' do
        email = TransactionMailer.payment_receipt_to_buyer(paypal_transaction)
        expect(email.body).to have_text('You have paid €5 for Sledgehammer. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text('Subtotal €5', normalize_ws: true)
        expect(email.body).to have_text('Total €5', normalize_ws: true)
      end

      it 'works with default payment gateway per hour' do
        email = TransactionMailer.payment_receipt_to_buyer(paypal_transaction_per_hour)
        expect(email.body).to have_text('You have paid €15 for Sledgehammer, per hour. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text('Price per hour €5', normalize_ws: true)
        expect(email.body).to have_text('Duration 3', normalize_ws: true)
        expect(email.body).to have_text('Subtotal €15', normalize_ws: true)
        expect(email.body).to have_text('Total €15', normalize_ws: true)
      end

      it 'works with stripe payment gateway' do
        email = TransactionMailer.payment_receipt_to_buyer(stripe_transaction)
        expect(email.body).to have_text('You have paid €2 for Sledgehammer. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text('Subtotal €2', normalize_ws: true)
        expect(email.body).to have_text('Total €2', normalize_ws: true)
      end

      it 'works with stripe payment gateway per hour' do
        email = TransactionMailer.payment_receipt_to_buyer(stripe_transaction_per_hour)
        expect(email.body).to have_text('You have paid €6 for Sledgehammer, per hour. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
        expect(email.body).to have_text('Price per hour €2', normalize_ws: true)
        expect(email.body).to have_text('Duration 3', normalize_ws: true)
        expect(email.body).to have_text('Subtotal €6', normalize_ws: true)
        expect(email.body).to have_text('Total €6', normalize_ws: true)
      end

      describe 'without buyer commission' do
        it 'works with default payment gateway' do
          email = TransactionMailer.payment_receipt_to_buyer(paypal_transaction)
          expect(email.body).to have_text('You have paid €5 for Sledgehammer. Here is your receipt.', normalize_ws: true)
        end

        it 'works with stripe payment gateway' do
          email = TransactionMailer.payment_receipt_to_buyer(stripe_transaction)
          expect(email.body).to have_text('You have paid €2 for Sledgehammer. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
        end
      end

      describe 'with buyer commission' do
        it 'works with stripe payment gateway' do
          email = TransactionMailer.payment_receipt_to_buyer(stripe_transaction_with_buyer_commission)
          expect(email.body).to have_text('You have paid €110 for Sledgehammer. The money is being held by Sharetribe until the order is marked as completed. Here is your receipt.', normalize_ws: true)
          expect(email.body).to have_text('Sharetribe service fee €8', normalize_ws: true)
          expect(email.body).to have_text('Total €110', normalize_ws: true)
        end
      end
    end
  end

  describe 'new transaction notification' do
    let(:community) { FactoryBot.create(:community) }
    let(:seller) {
      FactoryBot.create(:person, member_of: community,
                                 given_name: "Joan", family_name: "Smith")
    }
    let(:buyer) { FactoryBot.create(:person, member_of: community) }
    let(:listing) { FactoryBot.create(:listing, community_id: community.id, author: seller) }
    let(:paypal_transaction) do
      transaction = FactoryBot.create(:transaction, starter: buyer,
                                                    community: community, listing: listing,
                                                    current_state: 'paid', payment_gateway: 'paypal',
                                                    unit_price_cents: 500,
                                                    unit_price_currency: "EUR")
      FactoryBot.create(:paypal_payment, community_id: community.id, transaction_id: transaction.id,
                                         payment_total_cents: 500, fee_total_cents: 150, payment_status: "completed",
                                         commission_total_cents: 0, commission_fee_total_cents: 0)
      service_name(transaction.community_id)
      transaction
    end
    let(:admin) {
      FactoryBot.create(:person, member_of: community,
                                 given_name: "Estelle", family_name: "Perry")
    }

    it 'works' do
      email = TransactionMailer.new_transaction(paypal_transaction, admin)
      expect(email.body).to have_text('New transaction in Sharetribe')
      expect(email.body).to have_text('Listing: Sledgehammer', normalize_ws: true)
      expect(email.body).to have_text('Sum: €5', normalize_ws: true)
      expect(email.body).to have_text('Starter: Proto T', normalize_ws: true)
      expect(email.body).to have_text('Seller: Joan S', normalize_ws: true)
    end
  end

  def service_name(community_id)
    ApplicationHelper.store_community_service_name_to_thread_from_community_id(community_id)
  end
end
