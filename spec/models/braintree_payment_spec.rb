describe BraintreePayment do
  let(:community) { FactoryGirl.build(:community, commission_from_seller: 12) }
  let(:payment) { FactoryGirl.build(:braintree_payment, community: community, currency: "USD") }

  let(:community2) { FactoryGirl.build(:community, commission_from_seller: 10) }
  let(:payment2) { FactoryGirl.build(:braintree_payment, community: community2, currency: "USD") }

  describe "#total_commission" do
    it "calculates service fee from price and commission percentage" do
      payment.sum_cents = 10000
      payment.total_commission.cents.should == 1200
    end

    it "ceils the service fee" do
      payment.sum_cents = 500
      payment.total_commission.cents.should == 100

      payment2.sum_cents = 2900
      payment2.total_commission.cents.should == 300
    end
  end

  describe "seller_gets" do

    it "calculates sellers gets" do
      payment.sum_cents = 10000
      payment.seller_gets.cents.should == 8800

      payment2.sum_cents = 2900
      payment2.seller_gets.cents.should == 2600
    end
  end
end