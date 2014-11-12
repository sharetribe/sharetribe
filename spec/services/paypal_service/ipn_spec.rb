require 'spec_helper'

require_relative 'test_events'

describe PaypalService::IPN do
  before(:each) do
    @events = PaypalService::TestEvents.new

    @ipn_service = PaypalService::IPN.new(@events)

    @order = {
      order_total: 100,
      community_id: 1,
      transaction_id: 1,
      payer_id: "7LFUVCDKGARH4",
      receiver_id: "URAPMR7WHFAWY",
      pending_reason: "order",
      order_id: "O-2ES620817J8424036",
      order_date: Time.now,
      order_total: Money.new(1000, "GBP")
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

    @cid = 1
    @txid = 1

    PaypalService::Store::PaypalPayment.create(@cid, @txid, @order)
  end

  context "update payment" do
    it "should send event only on changed payment" do
      @ipn_service.handle_msg(@auth_created_msg)
      @ipn_service.handle_msg(@auth_created_msg)
      expect(@events.received_events[:payment_updated].length).to eq 1
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
      #at this point, our own service would complete payment and get fee in response
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
  end
end
