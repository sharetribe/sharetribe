import r from 'r-dom';
import { shallow } from 'enzyme';
import Immutable from 'immutable';

import { storify } from '../../Styleguide/withProps';
import { formatDistance, formatMoney } from '../../../utils/numbers';
import ListingModel from '../../../models/ListingModel';
import { Distance, Money } from '../../../types/types';
import { Image, ListingImage, AvatarImage } from '../../../models/ImageModel';

import ListingCard from './ListingCard';
import css from './ListingCard.story.css';

const { storiesOf, specs, expect } = storybookFacade;
const containerStyle = { style: { background: 'white' } };


const basicListingData = {
  id: 'lkjg84573874yjdf',
  title: 'Title',
  images: new Immutable.List([new ListingImage({
    square: new Image({
      url: 'https://placehold.it/408x408',
    }),
    square2x: new Image({
      type: 'square2x',
      width: 816,
      height: 816,
      url: 'https://placehold.it/816x816',
    }),
  })]),
  listingURL: 'https://example.com/listing/342iu4',
  orderType: new Immutable.Map({ en: 'Buy', fi: 'Osta' }),
  price: new Immutable.Map({
    ':money': new Money({
      fractionalAmount: 2147483647, // eslint-disable-line no-magic-numbers
      currency: 'EUR',
    }),
    ':pricingUnit': new Immutable.Map({ en: 'hundred centimeters' }),
  }),
  distance: new Distance({
    value: 12972, // eslint-disable-line no-magic-numbers
    unit: ':miles',
  }),
  author: {
    familyName: 'family name',
    givenName: 'given name',
    description: 'product author',
    avatarImage: new AvatarImage({ thumb: new Image({ url: 'https://placehold.it/40x40' }) }),
    profileURL: `#profile${Math.random(10)}`, // eslint-disable-line no-magic-numbers
  },
};

const ListingCardBasic =
  r(ListingCard, {
    className: css.listing,
    color: '#347F9D',
    listing: new ListingModel(basicListingData),
  });

const ListingCardNoImage =
  r(ListingCard,
    {
      className: css.listing,
      color: '#347F9D',
      listing: new ListingModel(Object.assign({}, basicListingData, {
        images: new Immutable.List(),
        price: new Immutable.Map({
          ':money': new Money({
            fractionalAmount: 1900, // eslint-disable-line no-magic-numbers
            currency: 'EUR',
          }),
          ':pricingUnit': new Immutable.Map({ en: 'day' }),
        }),
        distance: new Distance({
          value: 0.67, // eslint-disable-line no-magic-numbers
          unit: ':km',
        }),
      })),
    },
  );

const ListingCardImageError =
  r(ListingCard,
    {
      className: css.listing,
      color: '#347F9D',
      listing: new ListingModel(Object.assign({}, basicListingData, {
        title: 'Picture load fails',
        images: new Immutable.List([new ListingImage({
          square: new Image({ url: 'https://example.com/image.png' }),
          square2x: new Image({
            type: 'square2x',
            width: '816',
            height: '816',
            url: 'https://example.com/image@2x.png',
          }),
        })]),
        price: new Immutable.Map({
          ':money': new Money({
            fractionalAmount: 19900, // eslint-disable-line no-magic-numbers
            currency: 'EUR',
          }),
          ':pricingUnit': new Immutable.Map({ en: 'day' }),
        }),
        distance: new Distance({
          value: 9, // eslint-disable-line no-magic-numbers
          unit: ':miles',
        }),
      })),
    },
  );

const ListingCardNoPrice =
  r(ListingCard,
    {
      className: css.listing,
      color: '#347F9D',
      listing: new ListingModel(Object.assign({}, basicListingData, {
        orderType: new Immutable.Map({ en: 'Giving away', fi: 'Annetaan' }),
        price: null,
      })),
    },
  );


const testPrice = function testPrice(card, mountedCard) {
  it('Should display formatted price', () => {
    expect(mountedCard.text()).to.include(formatMoney(card.props.listing.price.get(':money'), card.props.listing.price.get(':priceUnit')));
    expect(mountedCard.find('.ListingCard_price')).to.have.length(1);
  });
  it('Should not display order type', () => {
    expect(mountedCard.text()).to.not.include(card.props.listing.orderType.get('en'));
    expect(mountedCard.find('.ListingCard_orderType')).to.have.length(0);
  });
};
const testDistance = function testDistance(card, mountedCard) {
  it('Should display formatted distance', () => {
    expect(mountedCard.text()).to.include(formatDistance(card.props.listing.distance));
  });
};


storiesOf('Search results')
  .add('ListingCard - basic', () => {
    const card = ListingCardBasic;
    const mountedCard = shallow(card);

    specs(() => describe('ListingCard - basic', () => {
      it('Should not display "No picture"', () => {
        expect(mountedCard.text()).to.not.include('No picture');
        expect(mountedCard.find('.ListingCard_image')).to.have.length(1);
      });
      testPrice(card, mountedCard);
      testDistance(card, mountedCard);
    }));

    return r(storify(card, containerStyle));
  })
  .add('ListingCard - no image', () => {
    const card = ListingCardNoImage;
    const mountedCard = shallow(card);

    specs(() => describe('ListingCard - no image', () => {
      it('Should display "No picture"', () => {
        expect(mountedCard.text()).to.include('No picture');
        expect(mountedCard.find('.ListingCard_image')).to.have.length(0);
      });
      testPrice(card, mountedCard);
      testDistance(card, mountedCard);
    }));

    return r(storify(card, containerStyle));
  })
  .add('ListingCard - image fail', () => {
    const card = ListingCardImageError;
    const mountedCard = shallow(card);

    specs(() => describe('ListingCard - image fail', () => {
      it('Should display "No picture"', () => {
        const mounted = shallow(card);
        mounted.setState({ imageStatus: 'failed' });
        expect(mounted.text()).to.include('No picture');
        expect(mounted.find('.ListingCard_image')).to.have.length(0);
      });
      testPrice(card, mountedCard);
      testDistance(card, mountedCard);
    }));

    return r(storify(card, containerStyle));
  })
  .add('ListingCard - no Price', () => {
    const card = ListingCardNoPrice;
    const mountedCard = shallow(card);

    specs(() => describe('ListingCard - basic', () => {
      it('Should display order type "Giving away"', () => {
        expect(mountedCard.text()).to.include(card.props.listing.orderType.get('en'));
        expect(mountedCard.find('.ListingCard_orderType')).to.have.length(1);
        expect(mountedCard.find('.ListingCard_price')).to.have.length(0);
      });
      testDistance(card, mountedCard);
    }));

    return r(storify(card, containerStyle));
  })
;
