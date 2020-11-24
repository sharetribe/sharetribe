window.ST = window.ST || {};

window.ST.listingImages = function(images) {

  function createStripe() {
    return ST.thumbnailStripe(images, {thumbnailWidth: 64, paddingAdjustment: 2});
  }

  function createCarousel() {
    return ST.imageCarousel(images);
  }

  var carousel = createCarousel();
  var stripe = createStripe();

  var LEFT = 37;
  var RIGHT = 39;

  var equals = _.curry(_.isEqual, 2);

  function keyCode(e) {
    return e.keyCode || e.which;
  }

  var keyCodeStream = $(document).asEventStream("keyup").map(keyCode);
  var keyboardLeft = keyCodeStream.filter(equals(LEFT));
  var keyboardRight = keyCodeStream.filter(equals(RIGHT));

  stripe.next(carousel.nextClicked);
  stripe.next(keyboardRight);
  stripe.prev(carousel.prevClicked);
  stripe.prev(keyboardLeft);

  carousel.next(keyboardRight);
  carousel.prev(keyboardLeft);
  carousel.show(stripe.show);
};