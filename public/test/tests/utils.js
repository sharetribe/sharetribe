describe('ST.utils', function () {
  it('#findNextIndex', function () {
    var f = ST.utils.findNextIndex;
    var even = function(a) { return a % 2 === 0; };

    expect(f([])).to.eql(-1);
    expect(f([1, 2, 3], even)).to.eql(2);
  });

  it('#contentTypeByFilename', function() {
    var f = ST.utils.contentTypeByFilename;

    expect(f("image.jpg")).to.eql("image/jpeg");
    expect(f("image.gif")).to.eql("image/gif");
    expect(f("image")).to.eql(undefined);
    expect(f("image.gif.png.jpg")).to.eql("image/jpeg");
  })
});