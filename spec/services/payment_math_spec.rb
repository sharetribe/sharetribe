describe PaymentMath do
  describe "#service_fee" do
    it "calculates service fee from price and commission percentage" do
      PaymentMath.service_fee(100, 12).should == 12
    end

    it "ceis the service fee" do
      PaymentMath.service_fee(5, 12).should == 1
    end
  end

  describe ":SellerCommission" do

    it "calculates sellers gets" do
      PaymentMath::SellerCommission.seller_gets(100, 12).should == 88
    end

    it "calculates buyers pays" do
      PaymentMath::SellerCommission.buyer_pays(100, 12).should == 100
    end
  end
end