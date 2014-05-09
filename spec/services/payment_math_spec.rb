describe PaymentMath do

  describe "#ceil_cents" do
    it "ceils to whole num" do
      PaymentMath.ceil_cents(100).should == 100
      PaymentMath.ceil_cents(110).should == 200
    end
  end
end
