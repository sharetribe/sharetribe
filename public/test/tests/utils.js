describe('ST.utils', function () {
  it('#findNextIndex', function () {
    var f = ST.utils.findNextIndex;
    var even = function(a) { return a % 2 === 0; };
    
    expect(f([])).to.eql(-1);
    expect(f([1, 2, 3], even)).to.eql(2);
  });
});