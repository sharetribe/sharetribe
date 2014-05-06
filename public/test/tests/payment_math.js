describe('paymentMath', function () {
  it('#serviceFee', function () {
    expect(ST.paymentMath.serviceFee(100, 12)).to.eql(12);
    expect(ST.paymentMath.serviceFee(100, 1/3*100)).to.eql(34);
  });

  it('#round', function() {
    expect(ST.paymentMath.round(100/3)).to.eql(33);
    expect(ST.paymentMath.round(100/3, 1)).to.eql(33.3);
    expect(ST.paymentMath.round(100/3, 2)).to.eql(33.33);
    expect(ST.paymentMath.round(100/3*2)).to.eql(67);
    expect(ST.paymentMath.round(100/3*2, 1)).to.eql(66.7);
    expect(ST.paymentMath.round(100/3*2, 2)).to.eql(66.67);
  });
});