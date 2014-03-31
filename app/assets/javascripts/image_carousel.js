window.ST = window.ST || {};

ST.imageCarousel = function(images, currentImageId) {
  var tmpl = _.template($("#image-frame-template").html());
  var leftLink = $("#listing-image-navi-left");
  var rightLink = $("#listing-image-navi-right");
  var container = $("#listing-image-frame");

  var imageIds = _(images).map(function(image) { return image.id }).value();
  var currentIdx = _.indexOf(imageIds, currentImageId);

  var elements = _.map(images, function(image) {
    return $(tmpl({url: image.images.big, aspectRatioClass: image.aspectRatio }));
  });

  _.each(elements, function(el) {
    el.hide();
    container.append(el);
  });

  elements[currentIdx].show();

  function prevId(currId, length) {
    if (currId === 0) {
      return length - 1;
    } else {
      return currId - 1
    }
  }

  function nextId(currId, length) {
    return (currId + 1) % length;
  }

  leftLink.asEventStream("click").doAction(".preventDefault").onValue(function() {
    var oldElement = elements[currentIdx];
    currentIdx = prevId(currentIdx, elements.length);
    var newElement = elements[currentIdx];

    oldElement.hide();
    newElement.show();
  });
  rightLink.asEventStream("click").doAction(".preventDefault").onValue(function() {
    var oldElement = elements[currentIdx];
    currentIdx = nextId(currentIdx, elements.length);
    var newElement = elements[currentIdx];

    oldElement.hide();
    newElement.show();
  });
}