import Immutable from 'immutable';

const ListingModel = Immutable.Record({
  id: 'uuid',
  title: 'Listing',
  images: [{
    square: 'foo',
    square2x: 'foo',
  }],
});

export const parse = (l) => new ListingModel({
  id: l.get(':id'),
  title: l.getIn([':attributes', ':title']),
  images: l.getIn([':attributes', ':images']),
});

export default ListingModel;
