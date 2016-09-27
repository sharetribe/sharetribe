import r from 'r-dom';
import { mount } from 'enzyme';

import { storify } from '../../Styleguide/withProps';
import { formatDistance, formatPrice } from '../../../utils/numbers';

import ListingCard from './ListingCard';
import css from './ListingCard.story.css';

const { storiesOf, specs, expect } = storybookFacade;
const containerStyle = { style: { background: 'white' } };

const ListingCardBasic =
  r(ListingCard,
    {
      id: 'lkjg84573874yjdf',
      title: 'Title',
      listingURL: 'http://marketplace.com/listing/342iu4',
      imageURL: 'https://placehold.it/408x408',
      image2xURL: 'https://placehold.it/816x816',
      noImageText: 'No picture',
      avatarURL: 'https://placehold.it/40x40',
      profileURL: '#profile1',
      price: 21474836.47,
      priceUnit: '€',
      per: '/ hundred centimeters',
      distance: 12972,
      distanceUnit: 'mi',
      color: '#347F9D',
      className: css.listing,
    },
  );

const ListingCardNoImage =
  r(ListingCard,
    {
      id: 'lkjg84573874yjdf',
      title: 'No picture',
      listingURL: 'http://marketplace.com/listing/342iu4',
      noImageText: 'No picture',
      avatarURL: 'https://placehold.it/40x40',
      profileURL: '#profile1',
      price: 19,
      priceUnit: '€',
      per: '/ day',
      distance: 0.67,
      distanceUnit: 'km',
      color: '#347F9D',
      className: css.listing,
    },
  );

const ListingCardImageError =
  r(ListingCard,
    {
      id: 'lkjg84573874yjdf',
      title: 'Picture load fails',
      listingURL: 'http://marketplace.com/listing/342iu4',
      imageURL: 'https://example.com/image.png',
      image2xURL: 'https://example.com/image@2x.png',
      noImageText: 'No picture',
      avatarURL: 'https://placehold.it/40x40',
      profileURL: '#profile1',
      price: 199,
      priceUnit: '€',
      distance: 9,
      distanceUnit: 'km',
      color: '#347F9D',
      className: css.listing,
    },
  );


const testPrice = function priceTest(card, mountedCard) {
  it('Should display formatted price', () => {
    expect(mountedCard.text()).to.include(formatPrice(card.props.price, card.props.priceUnit));
  });
};
const testDistance = function priceTest(card, mountedCard) {
  it('Should display formatted distance', () => {
    expect(mountedCard.text()).to.include(formatDistance(card.props.distance, card.props.distanceUnit));
  });
};


storiesOf('Search results')
  .add('ListingCard - basic', () => {
    const card = ListingCardBasic;
    const mountedCard = mount(card);

    specs(() => describe('ListingCard - basic', () => {
      it('Should not display "No picture"', () => {
        expect(mountedCard.text()).to.not.include(card.props.noImageText);
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
        expect(mountedCard.text()).to.include(card.props.noImageText);
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
        expect(mounted.text()).to.include(card.props.noImageText);
        expect(mounted.find('.ListingCard_image')).to.have.length(0);
      });
      testPrice(card, mountedCard);
      testDistance(card, mountedCard);
    }));

    return r(storify(ListingCardImageError, containerStyle));
  });
