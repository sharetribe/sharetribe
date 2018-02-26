require 'spec_helper'

describe MarketplaceService::Transaction::Entity do
  include MarketplaceService::Transaction::Entity

  it "#preauth_expires_at" do
    three_days = 3.days.from_now.at_beginning_of_day.utc
    six_days = 6.days.from_now.at_beginning_of_day.utc
    twelve_days = 12.days.from_now.at_beginning_of_day.utc
    expect(preauth_expires_at(six_days)).to eq(six_days)
    expect(preauth_expires_at(six_days, twelve_days)).to eq(six_days)
    expect(preauth_expires_at(six_days, three_days)).to eq(three_days + 2.days)

    # Works with Dates and Times
    expect(preauth_expires_at(six_days.to_date)).to eq(six_days.to_date.in_time_zone)
    expect(preauth_expires_at(six_days.to_date, three_days.to_date)).to eq((three_days  + 2.days).to_date.in_time_zone)
    expect(preauth_expires_at(six_days, three_days.to_date)).to eq((three_days  + 2.days).to_date.in_time_zone)
  end
end
