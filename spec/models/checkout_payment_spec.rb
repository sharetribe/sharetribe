require 'spec_helper'

describe CheckoutPayment do
  let(:row1) { FactoryGirl.build(:payment_row, :title => "old bikes", :vat => 24, :sum_cents => 2000) }
  let(:row2) { FactoryGirl.build(:payment_row, :title => "fixing", :vat => 24, :sum_cents => 10000) }
  let(:row3) { FactoryGirl.build(:payment_row, :title => "transport", :vat => 24, :sum_cents => 300) }
  let(:payment) { FactoryGirl.build(:checkout_payment, rows: [row1, row2, row3]) }

  describe "#summary_string" do
    it "returns the row titles joined with comma" do
      payment.summary_string.should == "old bikes, fixing, transport"
    end
  end

  describe "#total_sum" do
    it "sums rows" do
      payment.total_sum.cents.should == (2000 + 10000 + 300) * 1.24
    end
  end
end
