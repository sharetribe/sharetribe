window.ST = window.ST || {};

window.ST.listingImages = function(images, currentImageId) {

  function createStripe() {
    return ST.thumbnailStripe(images, {thumbnailWidth: 64, paddingAdjustment: 2});;
  }

  function createCarousel() {
    return ST.imageCarousel(images);
  }

  var carousel = createCarousel();
  var stripe = createStripe();

  stripe.next(carousel.next);
  stripe.prev(carousel.prev);
  carousel.show(stripe.show);
}