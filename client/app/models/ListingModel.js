import Immutable from 'immutable';
import { Image, ImageRefs } from './ImageModel';

export const Distance = Immutable.Record({
  value: 0,
  unit: 'km',
});

export const Money = Immutable.Record({
  fractionalAmount: 0,
  currency: 'USD',
});


const ListingModel = Immutable.Record({
  id: 'uuid',
  authorId: 'foo',
  distance: new Distance(),
  images: new Immutable.List([new ImageRefs({
    square: new Image(),
    square2x: new Image(),
  })]),
  price: new Immutable.Map({
    ':money': new Money(),
    ':pricingUnit': new Immutable.Map(),
  }),
  title: 'Listing',

  // these need to be updated
  author: new Immutable.Record(),
  listingURL: 'https://example.com/listing/1',
});

export const parse = (l) => new ListingModel({
  id: l.get(':id'),
  authorId: l.getIn([':relationships', ':author', ':id']),
  distance: l.getIn([':attributes', ':distance']),
  images: l.getIn([':attributes', ':images']),
  price: l.getIn([':attributes', ':price']),
  title: l.getIn([':attributes', ':title']),
});

export default ListingModel;
