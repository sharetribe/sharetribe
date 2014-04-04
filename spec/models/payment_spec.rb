require 'spec_helper'

describe Payment do
  describe "#summary_string" do
    it "returns the row titles joined with comma" do

      p = FactoryGirl.build(:payment)
      p.rows << PaymentRow.new(:title => "old bikes", :vat => 24, :currency => "EUR") #.update_attribute(:sum_cents, 1200)
      p.rows << PaymentRow.new(:title => "fixing", :vat => 24, :currency => "EUR")
      p.rows << PaymentRow.new(:title => "transport", :vat => 24, :currency => "EUR")

      p.summary_string.should == "old bikes, fixing, transport"
    end

  end
end
