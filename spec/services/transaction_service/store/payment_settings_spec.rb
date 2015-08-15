require 'spec_helper'

describe TransactionService::Store::PaymentSettings do

  PaymentSettings = TransactionService::Store::PaymentSettings

  it "sets commission_type for returned data" do
    expect(
      PaymentSettings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 50}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 50,
             minimum_price_cents: nil, commission_type: :both})

    expect(
      PaymentSettings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 0}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: 12, minimum_transaction_fee_cents: 0,
             minimum_price_cents: nil, commission_type: :relative})

    expect(
      PaymentSettings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14, commission_from_seller: 0, minimum_transaction_fee_cents: 50}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: 0, minimum_transaction_fee_cents: 50,
             minimum_price_cents: nil, commission_type: :fixed})

    expect(
      PaymentSettings.create(
      {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
       confirmation_after_days: 14}))
      .to eql(
            {community_id: 10, payment_gateway: :paypal, payment_process: :preauthorize, active: true,
             confirmation_after_days: 14, commission_from_seller: nil, minimum_transaction_fee_cents: nil,
             minimum_price_cents: nil, commission_type: :none})
  end
end
