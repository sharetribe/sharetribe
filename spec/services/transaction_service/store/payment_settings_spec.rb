require 'spec_helper'

describe TransactionService::Store::PaymentSettings do

  let(:payment_settings) { TransactionService::Store::PaymentSettings }

  it "sets commission_type for returned data" do
    expect(
      payment_settings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 50,
       minimum_transaction_fee_currency: "EUR"}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 50,
             minimum_transaction_fee_currency: "EUR", minimum_price_cents: nil, minimum_price_currency: nil,
             commission_type: :both})

    expect(
      payment_settings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 0,
       minimum_transaction_fee_currency: "USD"}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 0,
             minimum_transaction_fee_currency: "USD", minimum_price_cents: nil, minimum_price_currency: nil,
             commission_type: :relative})

    expect(
      payment_settings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14, commission_from_seller: 0, minimum_transaction_fee_cents: 50,
       minimum_transaction_fee_currency: "EUR"}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: 0, minimum_transaction_fee_cents: 50,
             minimum_transaction_fee_currency: "EUR", minimum_price_cents: nil, minimum_price_currency: nil,
             commission_type: :fixed})

    expect(
      payment_settings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: nil, minimum_transaction_fee_cents: nil,
             minimum_transaction_fee_currency: nil, minimum_price_cents: nil, minimum_price_currency: nil,
             commission_type: :none})
  end
end
