import Immutable from 'immutable';
import { Image, ListingImage } from './ImageModel';
import { Profile } from './ProfileModel';
import { Money, Distance } from '../types/types';

const ListingModel = Immutable.Record({
  id: 'uuid',
  title: 'Listing',
  distance: new Distance(),
  orderType: new Immutable.Map(),
  price: new Immutable.Map({
    ':money': new Money(),
    ':pricingUnit': new Immutable.Map(),
  }),
  images: new Immutable.List([new ListingImage({
    square: new Image(),
    square2x: new Image(),
  })]),
  authorId: 'foo',
  author: new Profile(),

  listingURL: '/listing/1',
  listingURLEdit: '/listing/1/edit',
});

const parseListingImages = (images) => new ListingImage({
  square: images.square,
  square2x: images.square2x,
});

export const parse = (l, getListingPath, getEditListingPath) => {
  const rawImages = l.getIn([':attributes', ':images']);
  const images = rawImages ? rawImages.map(parseListingImages) : new Immutable.List();
  return new ListingModel({
    id: l.get(':id'),
    extId: l.getIn([':attributes', ':extId']),
    distance: l.getIn([':attributes', ':distance']),
    images,
    listingURL: getListingPath(l.getIn([':attributes', ':extId'])),
    listingURLEdit: getEditListingPath(l.getIn([':attributes', ':extId'])),
    orderType: l.getIn([':attributes', ':orderType']),
    price: l.getIn([':attributes', ':price']),
    title: l.getIn([':attributes', ':title']),
    authorId: l.getIn([':relationships', ':author', ':id']),
  });
};

export default ListingModel;
