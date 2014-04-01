window.ST = window.ST || {};

ST.imageCarousel = function(images, currentImageId) {
  var tmpl = _.template($("#image-frame-template").html());
  var thumbnailTmpl = _.template($("#image-thumbnail-template").html());
  var leftLink = $("#listing-image-navi-left");
  var rightLink = $("#listing-image-navi-right");
  var container = $("#listing-image-frame");
  var thumbnailContainer = $("#listing-image-thumbnails");
  var thumbnailOverflow = $("#listing-image-thumbnails-mask");

  var imageIds = _(images).map(function(image) { return image.id }).value();
  var currentIdx = _.indexOf(imageIds, currentImageId);

  var elements = _.map(images, function(image) {
    return $(tmpl({url: image.images.big, aspectRatioClass: image.aspectRatio }));
  });

  var thumbnails = _.map(images, function(image) {
    return $(thumbnailTmpl({url: image.images.thumb }));
  });

  _.each(elements, function(el) {
    el.hide();
    container.append(el);
  });

  _.each(thumbnails, function(el) {
    thumbnailContainer.append(el);
  })

  elements[currentIdx].show();
  thumbnails[currentIdx].addClass("selected");

  var thumbnailWidth = thumbnails[0].width();

  thumbnailContainer.width(thumbnailWidth * thumbnails.length);

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
    var visibleWidth = thumbnailOverflow.width();

    thumbnails[currentIdx].removeClass("selected");
    var oldElement = elements[currentIdx];

    currentIdx = prevId(currentIdx, elements.length);

    var thumbnailPos = thumbnailWidth * currentIdx;

    if((visibleWidth - thumbnailPos) < thumbnailWidth) {
      thumbnailsMoved--;
      thumbnailContainer.transition({ x: (-1 * thumbnailsMoved * thumbnailWidth) });
    }

    thumbnails[currentIdx].addClass("selected");
    var newElement = elements[currentIdx];

    newElement.transition({ x: -1 * newElement.width() }, 0);
    newElement.show();
    var newDone = newElement.transition({ x: 0 }).promise();
    var oldDone = oldElement.transition({ x: newElement.width() }).promise();

    $.when(newDone, oldDone).done(function() {
      oldElement.hide();
    });
  });

  thumbnailsMoved = 0;

  rightLink.asEventStream("click").doAction(".preventDefault").onValue(function() {
    var visibleWidth = thumbnailOverflow.width();

    thumbnails[currentIdx].removeClass("selected");
    var oldElement = elements[currentIdx];

    currentIdx = nextId(currentIdx, elements.length);

    var thumbnailPos = thumbnailWidth * currentIdx;

    if((visibleWidth - thumbnailPos) < thumbnailWidth) {
      thumbnailsMoved++;
      thumbnailContainer.transition({ x: (-1 * thumbnailsMoved * thumbnailWidth) });
    }

    thumbnails[currentIdx].addClass("selected");
    var newElement = elements[currentIdx];

    newElement.transition({ x: newElement.width() }, 0);
    newElement.show();
    var newDone = newElement.transition({ x: 0 }).promise();
    var oldDone = oldElement.transition({ x: -1 * newElement.width() }).promise();

    $.when(newDone, oldDone).done(function() {
      oldElement.hide();
    });

  });
}