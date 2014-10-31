describe('paymentMath', function () {
  it('#totalCommission', function() {
    expect(ST.paymentMath.totalCommission(100, 0)).to.eql(0);
    expect(ST.paymentMath.totalCommission(100, 2)).to.eql(2);
    expect(ST.paymentMath.totalCommission(100, 2, 5).to.eql(5);
  })
});
