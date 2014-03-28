describe Util::MoneyUtil do
  it "#parse_money_to_cents" do
    Util::MoneyUtil.parse_money_to_cents("100").should eql(10000)
    Util::MoneyUtil.parse_money_to_cents("100.00").should eql(10000)
    Util::MoneyUtil.parse_money_to_cents("100,00").should eql(10000)
    Util::MoneyUtil.parse_money_to_cents("99,99").should eql(9999)
    Util::MoneyUtil.parse_money_to_cents("99.99").should eql(9999)
    Util::MoneyUtil.parse_money_to_cents("0.12").should eql(12)
    Util::MoneyUtil.parse_money_to_cents("0,12").should eql(12)
  end
end