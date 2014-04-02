describe('ST.utils', function () {
  it('#findNextIndex', function () {
    var f = ST.utils.findNextIndex;
    var even = function(a) { return a % 2 === 0; };

    expect(f([])).to.eql(-1);
    expect(f([1, 2, 3], even)).to.eql(2);
  });

  it('#nextIndex', function() {
    var f = ST.utils.nextIndex;

    var length = [0, 1, 2].length;

    expect(f(0, length)).to.eql(1);
    expect(f(1, length)).to.eql(2);
    expect(f(2, length)).to.eql(0);
  });

  it('#prevIndex', function() {
    var f = ST.utils.prevIndex;

    var length = [0, 1, 2].length;

    expect(f(2, length)).to.eql(1);
    expect(f(1, length)).to.eql(0);
    expect(f(0, length)).to.eql(2);
  });
});