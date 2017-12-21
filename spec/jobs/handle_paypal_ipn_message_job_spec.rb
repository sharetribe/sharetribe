require "spec_helper"

RSpec.describe HandlePaypalIpnMessageJob, type: :job do
  let(:community) { FactoryGirl.create(:community) }
  let(:transaction_process) { FactoryGirl.create(:transaction_process) }
  let(:listing) {
    FactoryGirl.create(:listing, community_id: community.id,
                                 listing_shape_id: 123,
                                 transaction_process_id: transaction_process.id)
  }
  let(:transaction) { FactoryGirl.create(:transaction, community: community, listing: listing, current_state: 'initiated') }
  let(:transaction2) { FactoryGirl.create(:transaction, community: community, listing: listing, current_state: 'initiated') }

  context '#perform' do
    it 'IPN message - commission denied' do
      body = {
        "mp_custom"=>"",
        "mc_gross"=>"50",
        "invoice"=>"#{community.id}-#{transaction.id}-commission",
        "mp_currency"=>"USD",
        "protection_eligibility"=>"Ineligible",
        "item_number1"=>"0",
        "payer_id"=>"EX3M7RJJ7ZZZZ",
        "tax"=>"0",
        "payment_date"=>"06:30:30 Oct 27, 2017 PDT",
        "mp_id"=>"B-3Y387433BA753ZZZZ",
        "payment_status"=>"Denied",
        "charset"=>"windows-1252",
        "mc_shipping"=>"0",
        "mc_handling"=>"0",
        "first_name"=>"Yosaton",
        "mp_status"=>"0",
        "notify_version"=>"3.8",
        "custom"=>"",
        "payer_status"=>"verified",
        "business"=>"nicolas@example.com",
        "num_cart_items"=>"1",
        "mc_handling1"=>"0",
        "verify_sign"=>"AESWI3GOfTYxKEwR5JMr8czKZUNdAmmdH4DvHAk5Ho8YBr1SUtSTZZZZ",
        "payer_email"=>"y.smith@example.com",
        "mc_shipping1"=>"0",
        "tax1"=>"0",
        "txn_id"=>"4N811936LY433ZZZZ",
        "payment_type"=>"instant",
        "last_name"=>"Smith",
        "mp_desc"=>"Grant Trezure permission to charge a transaction fee.",
        "item_name1"=>"Commission payment for Christmas Tree",
        "receiver_email"=>"nicolas@example.com",
        "mp_cycle_start"=>"15",
        "quantity1"=>"1",
        "receiver_id"=>"8WAHAZYS5ZZZZ",
        "txn_type"=>"merch_pmt",
        "mc_gross_1"=>"50",
        "mc_currency"=>"JPY",
        "residence_country"=>"US",
        "transaction_subject"=>"Marketplace vetterview took this commission from transaction regarding Christmas Tree",
        "payment_gross"=>"",
        "ipn_track_id"=>"22d763a05cccc",
        "controller"=>"paypal_ipn",
        "action"=>"ipn_hook"
      }
      paypal_ipn_message = FactoryGirl.create(:paypal_ipn_message, body: body, status: 'errored')
      paypal_payment = FactoryGirl.create(:paypal_payment,
                                          community_id: community.id,
                                          transaction_id: transaction.id,
                                          payment_status: 'completed',
                                          pending_reason: 'none',
                                          commission_payment_id: body["txn_id"])

      expect(paypal_payment.payment_status).to eq 'completed'
      expect(paypal_payment.commission_status).to eq 'pending'
      HandlePaypalIpnMessageJob.new(paypal_ipn_message.id).perform
      paypal_payment.reload
      expect(paypal_payment.payment_status).to eq 'completed'
      expect(paypal_payment.commission_status).to eq 'denied'
    end

    it 'IPN message - adjustment' do
      body = {
        "txn_type"=>"adjustment",
        "payment_date"=>"22:41:28 Nov 20, 2017 PST",
        "payment_gross"=>"-400.00",
        "mc_currency"=>"USD",
        "verify_sign"=>"Asm02AZo2GgXAq5vuJQw4xf2prDoA1AFaUqo9ytiIepWaLb.XyPciM1q",
        "payer_status"=>"verified",
        "payer_email"=>"thesubmarine@example.com",
        "txn_id"=>"4JJ10040D4671ZZZZ",
        "parent_txn_id"=>"1SS87354FT252ZZZZ",
        "payer_id"=>"LCLFGUWLCZZZZ",
        "invoice"=>"#{community.id}-#{transaction.id}-payment",
        "reason_code"=>"chargeback_settlement",
        "payment_status"=>"Completed",
        "payment_fee"=>"-20.00",
        "mc_gross"=>"-400.00",
        "charset"=>"windows-1252",
        "notify_version"=>"3.8",
        "ipn_track_id"=>"efc01da41aaaa",
        "controller"=>"paypal_ipn",
        "action"=>"ipn_hook",
      }
      paypal_ipn_message = FactoryGirl.create(:paypal_ipn_message, body: body, status: 'errored')
      paypal_payment = FactoryGirl.create(:paypal_payment,
                                          community_id: community.id,
                                          transaction_id: transaction.id,
                                          payment_status: 'completed',
                                          pending_reason: 'none',
                                          payment_id: body["parent_txn_id"],
                                          currency: 'USD',
                                          payment_total_cents: 40000,
                                          fee_total_cents: 1190,
                                          commission_status: 'completed',
                                          commission_pending_reason: 'none',
                                          commission_total_cents: 1200,
                                          commission_fee_total_cents: 65)

      HandlePaypalIpnMessageJob.new(paypal_ipn_message.id).perform
      paypal_payment.reload
      expect(paypal_payment.payment_total.cents).to eq 0
    end

    it 'IPN message - commission pending' do
      body = {
        "mp_custom"=>"",
        "mc_gross"=>"14.24",
        "invoice"=>"#{community.id}-#{transaction.id}-commission",
        "mp_currency"=>"EUR",
        "protection_eligibility"=>"Ineligible",
        "item_number1"=>"0",
        "tax"=>"0.00",
        "payer_id"=>"VRQ77S93WZZZZ",
        "payment_date"=>"04:55:19 Nov 22, 2017 PST",
        "mp_id"=>"B-92E30987Y6745ZZZZ",
        "payment_status"=>"Pending",
        "charset"=>"windows-1252",
        "mc_shipping"=>"0.00",
        "mc_handling"=>"0.00",
        "first_name"=>"Christophe",
        "mp_status"=>"0",
        "mc_fee"=>"0.73",
        "notify_version"=>"3.8",
        "custom"=>"",
        "payer_status"=>"unverified",
        "business"=>"morgane.regnier@example.com",
        "num_cart_items"=>"1",
        "mc_handling1"=>"0.00",
        "verify_sign"=>"AxGBlNtIj4ayGxxruDHIY.uLHHMXAyRZ-MtRqGDHKdl-ZMsWaxlb.qz0",
        "payer_email"=>"contact@example.com",
        "mc_shipping1"=>"0.00",
        "tax1"=>"0.00",
        "txn_id"=>"7B0631626J114ZZZZ",
        "payment_type"=>"instant",
        "payer_business_name"=>"chris-creation",
        "last_name"=>"Boury",
        "mp_desc"=>"Autoriser Experiences cours photo à prélever des frais de service.",
        "item_name1"=>"Paiement des frais de service pour Cours Lightroom - les bases - Bordeaux ou en ligne",
        "receiver_email"=>"morgane.regnier@photosqware.com",
        "payment_fee"=>"",
        "mp_cycle_start"=>"21",
        "quantity1"=>"1",
        "receiver_id"=>"K9D9EQZCWZZZZ",
        "pending_reason"=>"paymentreview",
        "txn_type"=>"merch_pmt",
        "mc_gross_1"=>"14.24",
        "mc_currency"=>"EUR",
        "residence_country"=>"FR",
        "transaction_subject"=>"La place de marché Experiences cours photo a prélevéces frais de service sur une transaction de Cours Lightroom - les bases",
        "payment_gross"=>"",
        "ipn_track_id"=>"84212dcfffff",
        "controller"=>"paypal_ipn",
        "action"=>"ipn_hook",
      }
      paypal_ipn_message = FactoryGirl.create(:paypal_ipn_message, body: body, status: 'errored')
      paypal_payment = FactoryGirl.create(:paypal_payment,
                                          community_id: community.id,
                                          transaction_id: transaction.id,
                                          payment_status: 'completed',
                                          pending_reason: 'none',
                                          commission_payment_id: body["txn_id"],
                                          commission_status: 'completed',
                                          commission_pending_reason: 'none')

      expect(paypal_payment.commission_pending_reason).to eq 'none'
      HandlePaypalIpnMessageJob.new(paypal_ipn_message.id).perform
      paypal_payment.reload
      expect(paypal_payment.commission_status).to eq 'pending'
      expect(paypal_payment.commission_pending_reason).to eq 'paymentreview'
    end

    it 'IPN message - fixed find paypal payment' do
      body = {
        "mc_gross"=>"40.50",
        "invoice"=>"31089-262964-payment",
        "auth_exp"=>"01:52:09 Jan 09, 2018 PST",
        "protection_eligibility"=>"Eligible",
        "address_status"=>"confirmed",
        "item_number1"=>"",
        "payer_id"=>"SMVUWVZCWZZZZ",
        "tax"=>"0.00",
        "address_street"=>"Alba Diagnostics Ltd 1 Bankhead Ave, Bankhead Ind Est",
        "payment_date"=>"01:52:09 Dec 11, 2017 PST",
        "payment_status"=>"Voided",
        "charset"=>"windows-1252",
        "address_zip"=>"KY7 6JG",
        "mc_shipping"=>"5.50",
        "mc_handling"=>"0.00",
        "first_name"=>"Stewart",
        "transaction_entity"=>"auth",
        "address_country_code"=>"GB",
        "address_name"=>"Stewart Whitton",
        "notify_version"=>"3.8",
        "custom"=>"",
        "payer_status"=>"unverified",
        "business"=>"info@peek-a-boo-signs.co.uk",
        "address_country"=>"United Kingdom",
        "num_cart_items"=>"1",
        "mc_handling1"=>"0.00",
        "address_city"=>"Glenrothes, Fife",
        "verify_sign"=>"AGXT66oAmwth6Mv574mMl8vl9PeuAJ8SBM.xnUQ4vETFvdkiEyxn18jL",
        "payer_email"=>"stewart@example.com",
        "mc_shipping1"=>"0.00",
        "tax1"=>"0.00",
        "parent_txn_id"=>"",
        "txn_id"=>"17834969M2791ZZZZ",
        "payment_type"=>"instant",
        "remaining_settle"=>"0",
        "auth_id"=>"17834969M2791ZZZZ",
        "last_name"=>"Whitton",
        "address_state"=>"Fife",
        "item_name1"=>"Wooden Sign \"How to tell time\"",
        "receiver_email"=>"info@example.com",
        "auth_amount"=>"40.50",
        "shipping_discount"=>"0.00",
        "quantity1"=>"1",
        "insurance_amount"=>"0.00",
        "receiver_id"=>"SRVAF3PNHZZZZ",
        "txn_type"=>"cart",
        "discount"=>"0.00",
        "mc_gross_1"=>"35.00",
        "mc_currency"=>"GBP",
        "residence_country"=>"GB",
        "shipping_method"=>"Default",
        "transaction_subject"=>"",
        "payment_gross"=>"",
        "auth_status"=>"Voided",
        "ipn_track_id"=>"7cc0a09bbbbbb",
        "controller"=>"paypal_ipn",
        "action"=>"ipn_hook"
      }
      paypal_ipn_message = FactoryGirl.create(:paypal_ipn_message, body: body, status: 'errored')
      FactoryGirl.create(:paypal_payment,
                                          community_id: community.id,
                                          transaction_id: transaction2.id,
                                          payment_status: 'voided',
                                          pending_reason: 'none',
                                          authorization_id: '111',
                                          commission_status: 'not_charged',
                                          commission_pending_reason: 'none')
      FactoryGirl.create(:paypal_payment,
                                          community_id: community.id,
                                          transaction_id: transaction.id,
                                          payment_status: 'voided',
                                          pending_reason: 'none',
                                          authorization_id: body["txn_id"],
                                          commission_status: 'not_charged',
                                          commission_pending_reason: 'none')
      expect{HandlePaypalIpnMessageJob.new(paypal_ipn_message.id).perform}.to_not raise_error
    end
  end
end
