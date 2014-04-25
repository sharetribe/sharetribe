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

    expect(f(length, 0)).to.eql(1);
    expect(f(length, 1)).to.eql(2);
    expect(f(length, 2)).to.eql(0);
  });

  it('#prevIndex', function() {
    var f = ST.utils.prevIndex;

    var length = [0, 1, 2].length;

    expect(f(length, 2)).to.eql(1);
    expect(f(length, 1)).to.eql(0);
    expect(f(length, 0)).to.eql(2);
  });

  it('#contentTypeByFilename', function() {
    var f = ST.utils.contentTypeByFilename;

    expect(f("image.jpg")).to.eql("image/jpeg");
    expect(f("image.JPG")).to.eql("image/jpeg");
    expect(f("image.gif")).to.eql("image/gif");
    expect(f("image")).to.eql(undefined);
    expect(f("image.gif.png.jpg")).to.eql("image/jpeg");
  });

  it("#stringToURLSafe", function() {
    var f = ST.utils.stringToURLSafe;

    expect(f("this_is_my_image")).to.eql("this_is_my_image");
    expect(f("This is John's super-cool image")).to.eql("this_is_john_s_super-cool_image");
  });

  it("#filenameToURLSafe", function() {
    var f = ST.utils.filenameToURLSafe;

    expect(f("this_is_my_image.jpg")).to.eql("this_is_my_image.jpg");
    expect(f("This is John's super-cool...image.JPG")).to.eql("this_is_john_s_super-cool___image.jpg");
  });
});