require 'spec_helper'

describe MoneyUtil do

  it "#to_dot_separated_str" do
    expect(MoneyUtil.to_dot_separated_str(Money.new(10001, "USD")))
      .to eq("100.01")

    expect(MoneyUtil.to_dot_separated_str(Money.new(10010, "USD")))
      .to eq("100.10")

    expect(MoneyUtil.to_dot_separated_str(Money.new(10000, "USD")))
      .to eq("100.00")

    expect(MoneyUtil.to_dot_separated_str(Money.new(50, "USD")))
      .to eq("0.50")

    expect(MoneyUtil.to_dot_separated_str(Money.new(2, "USD")))
      .to eq("0.02")
  end

end
