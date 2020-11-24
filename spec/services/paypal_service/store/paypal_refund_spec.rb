describe PaypalService::Store::PaypalRefund do
  payment_id = "3JA47865AL1892125"

  before(:each) do
    PaypalPayment.create(
      community_id: 1,
      transaction_id: 1,
      payer_id: "7LFUVCDKGARH4",
      receiver_id: "URAPMR7WHFAWY",
      merchant_id: "asdfasdf",
      order_id: "O-2ES620817J8424036",
      order_date: Time.now,
      currency: "GPB",
      order_total_cents: 1000,
      authorization_id: "4YD03796WG1628320",
      authorization_date: Time.now,
      authorization_expires_date: 14.days.from_now,
      authorization_total_cents: 1000,
      payment_id: payment_id,
      payment_date: Time.now,
      payment_total_cents: 1000,
      fee_total_cents: 10,
      payment_status: "completed",
      pending_reason: "none")

    @refund_data = {
      payment_id: payment_id,
      payment_total: Money.new(1000, "GBP"),
      fee_total: Money.new(10, "GBP"),
      refunding_id: "8PP35983D99952805"
    }
  end

  it "should create a refund model on refund" do
    PaypalService::Store::PaypalRefund.create(@refund_data)
    expect(PaypalRefund.count).to eq(1)
  end
end
