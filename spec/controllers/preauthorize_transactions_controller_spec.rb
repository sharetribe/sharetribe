require 'spec_helper'

describe PreauthorizeTransactionsController, type: :controller do



end

describe PreauthorizeTransactionsController::ItemTotal do

  ItemTotal = PreauthorizeTransactionsController::ItemTotal

  it "calculates the item total" do
    expect(ItemTotal.new(unit_price: Money.new(2500, "USD"), quantity: 10).total)
      .to eq(Money.new(25_000, "USD"))

    expect(ItemTotal.new(unit_price: Money.new(0, "EUR"), quantity: 10).total)
      .to eq(Money.new(0, "EUR"))

    expect(ItemTotal.new(unit_price: Money.new(2500, "USD"), quantity: 0).total)
      .to eq(Money.new(0, "USD"))
  end
end

describe PreauthorizeTransactionsController::ShippingTotal do

  ShippingTotal = PreauthorizeTransactionsController::ShippingTotal

  it "calculates the shipping total" do
    expect(ShippingTotal.new(initial: Money.new(5000, "EUR"), additional: 0, quantity: 1).total)
      .to eq(Money.new(5000, "EUR"))

    expect(ShippingTotal.new(initial: Money.new(5000, "EUR"), additional: 0, quantity: 10).total)
      .to eq(Money.new(5000, "EUR"))

    expect(ShippingTotal.new(initial: Money.new(5000, "USD"), additional: Money.new(1000, "USD"), quantity: 1).total)
      .to eq(Money.new(5000, "USD"))

    expect(ShippingTotal.new(initial: Money.new(5000, "USD"), additional: Money.new(1000, "USD"), quantity: 5).total)
      .to eq(Money.new(9000, "USD"))
  end
end

describe PreauthorizeTransactionsController::OrderTotal do

  OrderTotal = PreauthorizeTransactionsController::OrderTotal

  it "calculates the order total (item total + shipping total)" do
    items = ItemTotal.new(unit_price: Money.new(25_000, "EUR"), quantity: 5)
    shipping = ShippingTotal.new(initial: Money.new(2_000, "EUR"), additional: Money.new(500, "EUR"), quantity: 5)

    expect(OrderTotal.new(item_total: items, shipping_total: shipping).total)
      .to eq(Money.new(129_000, "EUR"))
  end
end
