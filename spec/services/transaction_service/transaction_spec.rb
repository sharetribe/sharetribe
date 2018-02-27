require 'spec_helper'

describe TransactionService::Transaction do
  let(:subject) { TransactionService::Transaction }

  context "#calculate_commission" do
    it "picks the largest of relative and fixed commission " do
      expect(subject.calculate_commission(Money.new(1000, "USD"), 10, Money.new(50, "USD")))
        .to eql Money.new(100, "USD")
      expect(subject.calculate_commission(Money.new(1000, "USD"), 10, Money.new(150, "USD")))
        .to eql Money.new(150, "USD")
    end

    it "handles nil percentage / min commission as zero" do
      expect(subject.calculate_commission(Money.new(1000, "USD"), nil, Money.new(50, "USD")))
        .to eql Money.new(50, "USD")
      expect(subject.calculate_commission(Money.new(1000, "USD"), 10, nil))
        .to eql Money.new(100, "USD")
      expect(subject.calculate_commission(Money.new(1000, "USD"), nil, nil))
        .to eql Money.new(0, "USD")
    end
  end

  context 'preauth_expires_at' do
    it "#preauth_expires_at" do
      three_days = 3.days.from_now.at_beginning_of_day.utc
      six_days = 6.days.from_now.at_beginning_of_day.utc
      twelve_days = 12.days.from_now.at_beginning_of_day.utc
      expect(subject.preauth_expires_at(six_days)).to eq(six_days)
      expect(subject.preauth_expires_at(six_days, twelve_days)).to eq(six_days)
      expect(subject.preauth_expires_at(six_days, three_days)).to eq(three_days + 2.days)

      # Works with Dates and Times
      expect(subject.preauth_expires_at(six_days.to_date)).to eq(six_days.to_date.in_time_zone)
      expect(subject.preauth_expires_at(six_days.to_date, three_days.to_date)).to eq((three_days  + 2.days).to_date.in_time_zone)
      expect(subject.preauth_expires_at(six_days, three_days.to_date)).to eq((three_days  + 2.days).to_date.in_time_zone)
    end
  end
end
