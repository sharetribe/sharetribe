import r from 'r-dom';
import { mount } from 'enzyme';
import Immutable from 'immutable';

import { storify } from '../../Styleguide/withProps';
import { formatDistance, formatPrice } from '../../../utils/numbers';
import ListingModel, { Image, ImageRefs } from '../../../models/ListingModel';

import ListingCard from './ListingCard';
import css from './ListingCard.story.css';

const { storiesOf, specs, expect } = storybookFacade;
const containerStyle = { style: { background: 'white' } };

const ListingCardBasic =
  r(ListingCard,
    {
      className: css.listing,
      color: '#347F9D',
      listing: new ListingModel({
        id: 'lkjg84573874yjdf',
        title: 'Title',
        images: new Immutable.List([new ImageRefs({
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
        avatarURL: 'https://placehold.it/40x40',
        profileURL: `#profile`,
        price: 21474836.47,  // eslint-disable-line no-magic-numbers
        priceUnit: '€',
        per: '/ hundred centimeters',
        distance: 12972,  // eslint-disable-line no-magic-numbers
        distanceUnit: 'mi',
      }),
    },
  );

const ListingCardNoImage =
  r(ListingCard,
    {
      className: css.listing,
      color: '#347F9D',
      listing: new ListingModel({
        id: 'lkjg84573874yjdf',
        title: 'No picture',
        images: new Immutable.List([new ImageRefs()]),
        listingURL: 'https://example.com/listing/342iu4',
        avatarURL: 'https://placehold.it/40x40',
        profileURL: `#profile`,
        price: 19,  // eslint-disable-line no-magic-numbers
        priceUnit: '€',
        per: '/ day',
        distance: 0.67,  // eslint-disable-line no-magic-numbers
        distanceUnit: 'km',
      }),
    },
  );

const ListingCardImageError =
  r(ListingCard,
    {
      className: css.listing,
      color: '#347F9D',
      listing: new ListingModel({
        id: 'lkjg84573874yjdf',
        title: 'Picture load fails',
        images: new Immutable.List([new ImageRefs({
          square: new Image({ url: 'https://example.com/image.png' }),
          square2x: new Image({
            type: 'square2x',
            width: '816',
            height: '816',
            url: 'https://example.com/image@2x.png',
          }),
        })]),
        listingURL: 'https://example.com/listing/342iu4',
        avatarURL: 'https://placehold.it/40x40',
        profileURL: `#profile`,
        price: 199,  // eslint-disable-line no-magic-numbers
        priceUnit: '€',
        per: '/ day',
        distance: 9,  // eslint-disable-line no-magic-numbers
        distanceUnit: 'km',
      }),
    },
  );


const testPrice = function priceTest(card, mountedCard) {
  it('Should display formatted price', () => {
    expect(mountedCard.text()).to.include(formatPrice(card.props.listing.get('price'), card.props.listing.get('priceUnit')));
  });
};
const testDistance = function priceTest(card, mountedCard) {
  it('Should display formatted distance', () => {
    expect(mountedCard.text()).to.include(formatDistance(card.props.listing.get('distance'), card.props.listing.get('distanceUnit')));
  });
};


storiesOf('Search results')
  .add('ListingCard - basic', () => {
    const card = ListingCardBasic;
    const mountedCard = mount(card);

    specs(() => describe('ListingCard - basic', () => {
      it('Should not display "No picture"', () => {
        expect(mountedCard.text()).to.not.include('No picture');
        expect(mountedCard.find('.ListingCard_image')).to.have.length(1);
      });
      testPrice(card, mountedCard);
      testDistance(card, mountedCard);
    }));

    return r(storify(ListingCardBasic, containerStyle));
  })
  .add('ListingCard - no image', () => {
    const card = ListingCardNoImage;
    const mountedCard = mount(card);

    specs(() => describe('ListingCard - no image', () => {
      it('Should display "No picture"', () => {
        expect(mountedCard.text()).to.include('No picture');
        expect(mountedCard.find('.ListingCard_image')).to.have.length(0);
      });
      testPrice(card, mountedCard);
      testDistance(card, mountedCard);
    }));

    return r(storify(ListingCardNoImage, containerStyle));
  })
  .add('ListingCard - image fail', () => {
    const card = ListingCardImageError;
    const mountedCard = mount(card);

    specs(() => describe('ListingCard - image fail', () => {
      it('Should display "No picture"', () => {
        const mounted = mount(card);
        mounted.setState({ imageStatus: 'failed' });
        expect(mounted.text()).to.include('No picture');
        expect(mounted.find('.ListingCard_image')).to.have.length(0);
      });
      testPrice(card, mountedCard);
      testDistance(card, mountedCard);
    }));

    return r(storify(ListingCardImageError, containerStyle));
  });
