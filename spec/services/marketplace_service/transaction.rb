describe MarketplaceService::Transaction::Entity do
  include MarketplaceService::Transaction::Entity

  it "#preauth_expires_at" do
    three_days = 3.days.from_now
    five_days = 5.days.from_now
    twelve_days = 12.days.from_now
    expect(preauth_expires_at(five_days)).to eq(five_days)
    expect(preauth_expires_at(five_days, twelve_days)).to eq(five_days)
    expect(preauth_expires_at(five_days, three_days)).to eq(three_days)

    # Works with Dates and Times
    expect(preauth_expires_at(five_days.to_date)).to eq(five_days.to_date.to_time)
    expect(preauth_expires_at(five_days.to_date, three_days.to_date)).to eq(three_days.to_date.to_time)
    expect(preauth_expires_at(five_days, three_days.to_date)).to eq(three_days.to_date.to_time)
  end
end
