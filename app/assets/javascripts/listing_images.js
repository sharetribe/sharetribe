window.ST = window.ST || {};

window.ST.listingImages = function(images, currentImageId) {
  var thumbnailTmpl = _.template($("#image-thumbnail-template").html());

  var carousel, stripe;

  function createStripe() {
    var _stripe;

    var thumbnails = _.map(images, function(image, idx) {
      var thumbnailElement = $(thumbnailTmpl({url: image.images.thumb }));
      thumbnailElement.click(function() {
        _stripe.show(idx);
        carousel.show(idx);
      });
      return thumbnailElement;
    });

    _stripe = ST.thumbnailStripe($("#thumbnail-stripe"), thumbnails, {thumbnailWidth: 64, paddingAdjustment: 2});

    _stripe.show(0);

    return _stripe;
  }

  function createCarousel() {
    var _carousel = ST.imageCarousel(images, currentImageId);
    _carousel.next.onValue(function() {
      stripe.next()}
    );
    _carousel.prev.onValue(function() {
      stripe.prev();
    });

    return _carousel;
  }

  carousel = createCarousel();
  stripe = createStripe();

}