describe DateUtils do
  it "#duration" do
    # end date is excluded
    expect(DateUtils.duration(Date.new(2014, 10, 28), Date.new(2014, 10, 29))).to eql(1)
    expect(DateUtils.duration(Date.new(2014, 10, 28), Date.new(2014, 10, 30))).to eql(2)
  end
end
