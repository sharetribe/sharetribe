describe PaymentMath do
  describe "#service_fee" do
    it "calculates service fee from price and commission percentage" do
      PaymentMath.service_fee(10000, 12).should == 1200
    end

    it "ceils the service fee" do
      PaymentMath.service_fee(500, 12).should == 100
      PaymentMath.service_fee(2900, 10).should == 300
    end
  end

  describe "#ceil_cents" do
    it "ceils to whole num" do
      PaymentMath.ceil_cents(100).should == 100
      PaymentMath.ceil_cents(110).should == 200
    end
  end

  describe ":SellerCommission" do

    it "calculates sellers gets" do
      PaymentMath::SellerCommission.seller_gets(10000, 12).should == 8800
      PaymentMath::SellerCommission.seller_gets(2900, 10).should == 2600
    end
  end
end
