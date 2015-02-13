describe DateUtils do
  it "#duration_days" do
    # end date is included
    expect(DateUtils.duration_days(Date.new(2014, 10, 28), Date.new(2014, 10, 28))).to eql(1)
    expect(DateUtils.duration_days(Date.new(2014, 10, 28), Date.new(2014, 10, 29))).to eql(2)
  end
end
