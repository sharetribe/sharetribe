require 'spec_helper'

describe PreauthorizeTransactionsController, type: :controller do



end

describe PreauthorizeTransactionsController::ItemTotal do

  let(:item_total) { PreauthorizeTransactionsController::ItemTotal }

  it "calculates the item total" do
    expect(item_total.new(unit_price: Money.new(2500, "USD"), quantity: 10).total)
      .to eq(Money.new(25_000, "USD"))

    expect(item_total.new(unit_price: Money.new(0, "EUR"), quantity: 10).total)
      .to eq(Money.new(0, "EUR"))

    expect(item_total.new(unit_price: Money.new(2500, "USD"), quantity: 0).total)
      .to eq(Money.new(0, "USD"))
  end
end

describe PreauthorizeTransactionsController::ShippingTotal do

  let(:shipping_total) { PreauthorizeTransactionsController::ShippingTotal }

  it "calculates the shipping total" do
    expect(shipping_total.new(initial: Money.new(5000, "EUR"), additional: 0, quantity: 1).total)
      .to eq(Money.new(5000, "EUR"))

    expect(shipping_total.new(initial: Money.new(5000, "EUR"), additional: 0, quantity: 10).total)
      .to eq(Money.new(5000, "EUR"))

    expect(shipping_total.new(initial: Money.new(5000, "USD"), additional: Money.new(1000, "USD"), quantity: 1).total)
      .to eq(Money.new(5000, "USD"))

    expect(shipping_total.new(initial: Money.new(5000, "USD"), additional: Money.new(1000, "USD"), quantity: 5).total)
      .to eq(Money.new(9000, "USD"))
  end
end

describe PreauthorizeTransactionsController::OrderTotal do

  let(:item_total) { PreauthorizeTransactionsController::ItemTotal }
  let(:shipping_total) { PreauthorizeTransactionsController::ShippingTotal }
  let(:order_total) { PreauthorizeTransactionsController::OrderTotal }

  it "calculates the order total (item total + shipping total)" do
    items = item_total.new(unit_price: Money.new(25_000, "EUR"), quantity: 5)
    shipping = shipping_total.new(initial: Money.new(2_000, "EUR"), additional: Money.new(500, "EUR"), quantity: 5)

    expect(order_total.new(item_total: items, shipping_total: shipping).total)
      .to eq(Money.new(129_000, "EUR"))
  end
end
