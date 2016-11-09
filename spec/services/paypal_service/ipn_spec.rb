require 'spec_helper'

describe PaypalService::IPN do

  let(:account_store) { PaypalService::Store::PaypalAccount }

  before(:each) do
    @events = PaypalService::TestEvents.new

    @ipn_service = PaypalService::IPN.new(@events)

    @billing_agreement_created = {
      :type=>:billing_agreement_created,
      :billing_agreement_id=>"B-80N6310848330024M",
      :payer_id=>"P6S3ZMLQ25AYU",
      :payer_email=>"dev+paypal_us@sharetribe.com",
      :payer_status=>"verified"
    }

    @billing_agreement_cancelled = {
      type: :billing_agreement_cancelled,
      payer_email: "dev+paypal_us@sharetribe.com",
      payer_id: "payer_id_1",
      billing_agreement_id: "bagrid"
    }

    @order = {
      community_id: 1,
      transaction_id: 1,
      payer_id: "7LFUVCDKGARH4",
      receiver_id: "URAPMR7WHFAWY",
      merchant_id: "asdfasdf",
      pending_reason: "order",
      order_id: "O-2ES620817J8424036",
      order_date: Time.now,
      order_total: Money.new(1000, "GBP")
    }

    @authorization = {
      community_id: 1,
      transaction_id: 2,
      payer_id: "7LFUVCDKGARH4",
      receiver_id: "URAPMR7WHFAWY",
      merchant_id: "asdfasdf",
      pending_reason: "authorization",
      authorization_id: "O-2ES620817J8424038",
      authorzation_date: Time.now,
      authorization_total: Money.new(1000, "GBP")
    }

    @auth_created_msg = {
      type: :authorization_created,
      authorization_date: "2014-10-01 09:04:07 +0300",
      authorization_expires_date: "2014-10-04 09:50:00 +0300",
      order_id: "O-2ES620817J8424036",
      authorization_id: "0L584749FU2628910",
      payer_email: "foobar@barfoo.com",
      payer_id: "7LFUVCDKGARH4",
      receiver_email: "dev+paypal-user1@sharetribe.com",
      receiver_id: "URAPMR7WHFAWY",
      payment_status: "Pending",
      pending_reason: "authorization",
      receipt_id: "3609-0935-6989-4532",
      order_total: Money.new(120, "GBP"),
      authorization_total: Money.new(120, "GBP")
    }

    @auth_created_no_order_msg = {
      type: :authorization_created,
      authorization_date: "2014-10-01 09:04:07 +0300",
      authorization_expires_date: "2014-10-04 09:50:00 +0300",
      order_id: nil,
      authorization_id: "O-2ES620817J8424038",
      payer_email: "foobar@barfoo.com",
      payer_id: "7LFUVCDKGARH4",
      receiver_email: "dev+paypal-user1@sharetribe.com",
      receiver_id: "URAPMR7WHFAWY",
      payment_status: "Pending",
      pending_reason: "authorization",
      receipt_id: "3609-0935-6989-4532",
      order_total: nil,
      authorization_total: Money.new(120, "GBP")
    }

    @payment_review_no_order_msg = {
      type: :payment_review,
      authorization_date: "2014-10-01 09:04:07 +0300",
      authorization_expires_date: "2014-10-04 09:50:00 +0300",
      authorization_id: "O-2ES620817J8424038",
      payer_email: "foobar@barfoo.com",
      payer_id: "7LFUVCDKGARH4",
      receiver_email: "dev+paypal-user1@sharetribe.com",
      receiver_id: "URAPMR7WHFAWY",
      payment_status: "Pending",
      pending_reason: "payment-review",
      receipt_id: "3609-0935-6989-4532",
      authorization_total: Money.new(120, "GBP")
    }

    @auth_expired_msg = {
      type: :authorization_expired,
      authorization_id: "0L584749FU2628910",
      order_id: "O-2ES620817J8424036",
      payment_status: "Expired"
    }

    @order_created_msg = {
      type: :order_created,
      order_date:  "2014-10-01 09:04:07 +0300",
      order_id: "O-2ES620817J8424036",
      payer_email: "foobar@barfoo.com",
      payer_id: "7LFUVCDKGARH4",
      receiver_email: "dev+paypal-user1@sharetribe.com",
      receiver_id: "URAPMR7WHFAWY",
      payment_status: "Pending",
      pending_reason: "order",
      receipt_id: "3609-0935-6989-4532",
      order_total: Money.new(120, "GBP")
    }

    @pending_ext_msg = {
      type: :payment_pending_ext,
      pending_ext_id: "12345679",
      authorization_date: "2014-10-01 09:04:07 +0300",
      authorization_expires_date: "2014-10-04 09:50:00 +0300",
      authorization_id: "0L584749FU2628910",
      payer_email: "foobar@barfoo.com",
      payer_id: "7LFUVCDKGARH4",
      receiver_email: "dev+paypal-user1@sharetribe.com",
      receiver_id: "URAPMR7WHFAWY",
      payment_status: "Pending",
      pending_reason: "multi-currency",
      receipt_id: "3609-0935-6989-4532",
      authorization_total: Money.new(120, "GBP"),
      payment_total: Money.new(120, "GBP")
    }

    @payment_completed_msg = {
      type: :payment_completed,
      payment_date: "2014-11-10 15:32:02 +0200",
      payment_id: "0J90171846752303G",
      authorization_expires_date: "2014-11-14 09:50:02 +0200",
      authorization_id: "0L584749FU2628910",
      payer_email: "payper@ex.com",
      payer_id: "HTLEEXWH2GJ5H",
      receiver_email: "receiver@ex.com",
      receiver_id: "XAOENU6KNJRCWC",
      payment_status: "Completed",
      pending_reason: :none,
      receipt_id:  nil,
      authorization_total:  Money.new(120, "GBP"),
      payment_total:  Money.new(120, "GBP"),
      fee_total: nil
   }

    @payment_refunded_msg = {
      type: :payment_refunded,
      refunding_id: "7HX881531H984174B",
      refunded_date: "2014-10-01 09:24:36 +0300",
      payment_id: "0J90171846752303G",
      authorization_id: nil,
      payer_email: "foobar@barfoo.com",
      payer_id: "6M39X6RCYVUD6",
      receiver_email: "dev+paypal-user1@sharetribe.com",
      receiver_id: "URAPMR7WHFAWY",
      payment_status: "Refunded",
      pending_reason: :none,
      receipt_id: nil,
      authorization_total: nil,
      payment_total: Money.new(120, "GBP"),
      fee_total: Money.new(4, "GBP")
    }

    @commission_refunded_msg = {
      type: :payment_refunded,
      refunding_id: "7HX881531H984174B",
      refunded_date: "2014-10-01 09:24:36 +0300",
      payment_id: "5SB7123462UR2969339",
      authorization_id: nil,
      payer_email: "foobar@barfoo.com",
      payer_id: "6M39X6RCYVUD6",
      receiver_email: "dev+paypal-user1@sharetribe.com",
      receiver_id: "URAPMR7WHFAWY",
      payment_status: "Refunded",
      pending_reason: :none,
      receipt_id: nil,
      authorization_total: nil,
      payment_total: Money.new(120, "GBP"),
      fee_total: Money.new(4, "GBP")
    }

    @payment_denied_msg = {
      type: :payment_denied,
      payer_email: "payer@sharetribe.com",
      payer_id: "XXXSNUI6KNJRCWC",
      receiver_id: "HTLXESTNHJ5W",
      receiver_email: "receiver@sharetribe.com",
      authorization_id: "0L584749FU2628910",
      payment_id: "0J90171846752303G",
      payment_status: :denied,
      pending_reason: :none
    }

    @commission_paid_msg = {
      type: :commission_paid,
      commission_status: "Completed",
      commission_payment_id: "5SB7123462UR2969339",
      commission_total: Money.new(174, "GBP"),
      commission_fee_total: Money.new(10, "GBP"),
      invnum: "1-1-commission"
    }

    @commission_pending_ext_msg = {
      type: :commission_pending_ext,
      commission_status: "Pending",
      commission_pending_reason: "multi_currency",
      commission_payment_id: "5SB7123462UR2969339",
      commission_total: Money.new(174, "GBP"),
      invnum: "1-1-commission"
    }

    @cid = 1
    @txid = 1
    @txid_auth = 2
    @mid = "merchant_id_1"
    @payer_id = "payer_id_1"
    @paypal_email = "merchant_1@test.com"
    @paypal_email_admin = "admin_2@test.com"
    @billing_agreement_id = "bagrid"

    PaypalService::Store::PaypalPayment.create(@cid, @txid, @order)
    PaypalService::Store::PaypalPayment.create(@cid, @txid_auth, @authorization)

    account_store.create(
      opts:
        {
          active: true,
          person_id: @mid,
          community_id: @cid,
          email: @paypal_email,
          payer_id: @payer_id,
          order_permission_paypal_username_to: @paypal_email_admin,
          order_permission_request_token: "123456789",
          billing_agreement_billing_agreement_id: @billing_agreement_id,
          billing_agreement_request_token: "B-123456789",
          billing_agreement_paypal_username_to: @paypal_email_admin
        })
  end

  context "update payment" do
    it "should send event only on changed payment" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@auth_created_msg)
      expect(@events.received_events[:payment_updated].length).to eq 1
    end

    it "should keep payment in payment-review when payment-review ipn msg received" do
      PaypalPayment.where(authorization_id: @authorization[:authorization_id])
        .first
        .update_attribute(:pending_reason, "payment-review")

      @ipn_service.handle_msg(@payment_review_no_order_msg)
      payment = PaypalPayment.where(authorization_id: @authorization[:authorization_id]).first
      expect(payment.payment_status).to eql "pending"
      expect(payment.pending_reason).to eql "payment-review"
    end

    it "should handle authorization when payment in payment-review state" do
      PaypalPayment.where(authorization_id: @authorization[:authorization_id])
        .first
        .update_attribute(:pending_reason, "payment-review")

      @ipn_service.handle_msg(@auth_created_no_order_msg)
      payment = PaypalPayment.where(authorization_id: @authorization[:authorization_id]).first
      expect(payment.payment_status).to eql "pending"
      expect(payment.pending_reason).to eql "authorization"
    end

    it "should handle authorization without order" do
      @ipn_service.handle_msg(@auth_created_no_order_msg)

      payment = PaypalPayment.where(authorization_id: @authorization[:authorization_id]).first
      expect(payment.payment_status).to eql "pending"
      expect(payment.pending_reason).to eql "authorization"
    end

    it "should not move authorized payment to payment-review is ipns arrive out of order" do
      @ipn_service.handle_msg(@auth_created_no_order_msg)
      @ipn_service.handle_msg(@payment_review_no_order_msg)

      payment = PaypalPayment.where(authorization_id: @authorization[:authorization_id]).first
      expect(payment.payment_status).to eql "pending"
      expect(payment.pending_reason).to eql "authorization"
    end

    it "shouldn't move backwards in state" do
      @ipn_service.handle_msg(@auth_created_msg)
      expect(PaypalPayment.first.pending_reason).to eql "authorization"
      @ipn_service.handle_msg(@order_created_msg)
      expect(PaypalPayment.first.pending_reason).to eql "authorization"
    end

    it "should update to pending ext from authorization" do
      @ipn_service.handle_msg(@auth_created_msg)
      expect(PaypalPayment.first.pending_reason).to eql "authorization"
      @ipn_service.handle_msg(@pending_ext_msg)
      expect(PaypalPayment.first.pending_reason).to eql "multicurrency"
    end

    it "should keep the fee_total even if ipn completed does not have it" do
      @ipn_service.handle_msg(@auth_created_msg)
      # at this point, our own service would complete payment and get fee in response
      PaypalPayment.first.update_attribute(:fee_total, Money.new(100, "GBP"))
      @ipn_service.handle_msg(@payment_completed_msg)
      expect(PaypalPayment.first.fee_total)
    end

    it "should create refund" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@payment_completed_msg)
      @ipn_service.handle_msg(@payment_refunded_msg)
      expect(PaypalRefund.count).to eql 1
    end

    it "should deny payment" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@payment_denied_msg)

      payment = PaypalPayment.first
      expect(payment.pending_reason).to eql "none"
      expect(payment.payment_status).to eql "denied"
    end

    it "should handle commission" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@payment_completed_msg)
      @ipn_service.handle_msg(@commission_paid_msg)

      payment = PaypalPayment.first
      expect(payment.commission_total).to eql Money.new(174, "GBP")
      expect(payment.commission_fee_total).to eql Money.new(10, "GBP")
    end

    it "should handle commission pending ext" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@payment_completed_msg)
      @ipn_service.handle_msg(@commission_pending_ext_msg)

      payment = PaypalPayment.first
      expect(payment.commission_total).to eql Money.new(174, "GBP")
      expect(payment.commission_status).to eql "pending"
      expect(payment.commission_pending_reason).to eql "multicurrency"
    end

    it "should handle commission refunded" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@payment_completed_msg)
      @ipn_service.handle_msg(@commission_paid_msg)
      @ipn_service.handle_msg(@commission_refunded_msg)

      expect(PaypalRefund.count).to eql 1
    end

    it "should handle authorization expired" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@auth_expired_msg)

      payment = PaypalPayment.first
      expect(payment.payment_status).to eql "expired"
    end

    it "should handle billing agreement created" do
      expect(@ipn_service.handle_msg(@billing_agreement_created)).to eql true
    end

    it "should handle billing agreement cancelled" do
      acc = account_store.get_active(
        person_id: @mid,
        community_id: @cid
      )
      expect(acc[:billing_agreement_state]).to eql(:verified)
      expect(acc[:billing_agreement_billing_agreement_id]).to eql(@billing_agreement_id)

      @ipn_service.handle_msg(@billing_agreement_cancelled)

      acc2 = account_store.get_active(
        person_id: @mid,
        community_id: @cid
      )
      expect(acc2[:billing_agreement_state]).to eql(:not_verified)
      expect(acc2[:billing_agreement_billing_agreement_id]).to be_nil
    end
  end

  context "async handling" do
    before(:each) do
      @auth_created_params = {
        "mc_gross"=>"1.20",
        "auth_exp"=>"23:50:00 Oct 03, 2014 PDT",
        "protection_eligibility"=>"Ineligible",
        "payer_id"=>"7LFUVCDKGARH",
        "tax"=>"0.00",
        "payment_date"=>"23:04:07 Sep 30, 2014 PDT",
        "payment_status"=>"Pending",
        "charset"=>"windows-1252",
        "first_name"=>"ljkh",
        "transaction_entity"=>"auth",
        "notify_version"=>"3.8",
        "custom"=>"",
        "payer_status"=>"unverified",
        "quantity"=>"1",
        "verify_sign"=>"A2S1fniRGsoquzRDbs4f5rc383f8A9BZtlhOnNThbBpkIOUsU.U6RJlP",
        "payer_email"=>"foobar@barfoo.com",
        "parent_txn_id"=>"O-2ES620817J8424036",
        "txn_id"=>"0L584749FU2628910",
        "payment_type"=>"instant",
        "remaining_settle"=>"10",
        "auth_id"=>"0L584749FU2628910",
        "last_name"=>"kjh",
        "receiver_email"=>"dev+paypal-user1@sharetribe.com",
        "auth_amount"=>"1.20",
        "receiver_id"=>"URAPMR7WHFAWY",
        "pending_reason"=>"authorization",
        "txn_type"=>"express_checkout",
        "item_name"=>"desc",
        "mc_currency"=>"GBP",
        "item_number"=>"",
        "residence_country"=>"GB",
        "test_ipn"=>"1",
        "receipt_id"=>"3609-0935-6989-4532",
        "handling_amount"=>"0.00",
        "transaction_subject"=>"",
        "payment_gross"=>"",
        "auth_status"=>"Pending",
        "shipping"=>"0.00",
        "ipn_track_id"=>"35b2bed5966"
      }.with_indifferent_access

      SyncDelayedJobObserver.reset!
    end

    after(:each) do
      SyncDelayedJobObserver.reset!
    end

    it "should store and handle ipn messages asynchronously" do
      SyncDelayedJobObserver.collect!

      @ipn_service.store_and_create_handler(@auth_created_params)

      expect(PaypalIpnMessage.count).to eql 1
      expect(PaypalIpnMessage.first.status).to eql nil

      SyncDelayedJobObserver.process_queue!

      expect(SyncDelayedJobObserver.total_processed).to eql 1

      expect(PaypalIpnMessage.first.status).to eql :success
    end

  end
end
