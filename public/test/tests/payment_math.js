describe('paymentMath', function () {
  it('#totalCommission', function() {
    expect(ST.paymentMath.totalCommission(100, 0, 8, 0)).to.eql(8);
    expect(ST.paymentMath.totalCommission(100, 0, 8, 0.5)).to.eql(9);
    expect(ST.paymentMath.totalCommission(100, 2, 8, 0.5)).to.eql(11);
  })
});