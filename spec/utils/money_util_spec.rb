require 'spec_helper'

describe MoneyUtil do

  it "#parse_str_to_money" do
    expect(MoneyUtil.parse_str_to_money("5000", "JPY"))
      .to eql(Money.new(5000, "JPY"))
    expect(MoneyUtil.parse_str_to_money("50", "EUR"))
      .to eql(Money.new(5000, "EUR"))
    expect(MoneyUtil.parse_str_to_money("0.12", "USD"))
      .to eql(Money.new(12, "USD"))
    expect(MoneyUtil.parse_str_to_money("0,12", "EUR"))
      .to eql(Money.new(12, "EUR"))
    expect(MoneyUtil.parse_str_to_money("0,1", "EUR"))
      .to eql(Money.new(10, "EUR"))
    expect(MoneyUtil.parse_str_to_money("0,06", "EUR"))
      .to eql(Money.new(6, "EUR"))
    expect(MoneyUtil.parse_str_to_money(".05", "EUR"))
      .to eql(Money.new(5, "EUR"))
  end

  it "#parse_str_to_subunits" do
    expect(MoneyUtil.parse_str_to_subunits("100", "EUR")).to eql(10000)
    expect(MoneyUtil.parse_str_to_subunits("100.00", "EUR")).to eql(10000)
    expect(MoneyUtil.parse_str_to_subunits("100,00", "EUR")).to eql(10000)
    expect(MoneyUtil.parse_str_to_subunits("99,99", "EUR")).to eql(9999)
    expect(MoneyUtil.parse_str_to_subunits("99.99", "EUR")).to eql(9999)
    expect(MoneyUtil.parse_str_to_subunits("0.12", "EUR")).to eql(12)
    expect(MoneyUtil.parse_str_to_subunits("2.32", "EUR")).to eql(232)
    expect(MoneyUtil.parse_str_to_subunits("0,12", "EUR")).to eql(12)
    expect(MoneyUtil.parse_str_to_subunits("0,1", "EUR")).to eql(10)
    expect(MoneyUtil.parse_str_to_subunits(".03", "EUR")).to eql(3)
    expect(MoneyUtil.parse_str_to_subunits("10", "JPY")).to eql(10)
  end

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
