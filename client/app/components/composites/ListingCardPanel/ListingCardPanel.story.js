import r from 'r-dom';
import { mount } from 'enzyme';
import Immutable from 'immutable';

import { storify } from '../../Styleguide/withProps';
import { toFixedNumber } from '../../../utils/numbers';
import ListingModel from '../../../models/ListingModel';
import { Distance, Money } from '../../../types/types';
import { Image, ListingImage, AvatarImage } from '../../../models/ImageModel';

import ListingCardPanel from '../ListingCardPanel/ListingCardPanel';
import ListingCard from '../ListingCard/ListingCard';

const LISTINGS_COUNT = 24;

const { storiesOf, specs, expect } = storybookFacade;
const containerStyle = { style: { background: 'white' } };


const listingCardTemplate = (title, perUnit, price, distance) => (
  r(ListingCard,
    {
      color: '#347F9D',
      listing: new ListingModel({
        id: 'lkjg84573874yjdf',
        title,
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
        price: new Immutable.Map({
          ':money': new Money({
            fractionalAmount: price || toFixedNumber(Math.random() * 9999, 2), // eslint-disable-line no-magic-numbers
            currency: 'EUR',
          }),
          ':pricingUnit': new Immutable.Map({ en: (perUnit || 'day'), fi: 'päivä' }),
        }),
        distance: new Distance({
          value: distance || Math.random() * (20000) + 0.01, // eslint-disable-line no-magic-numbers
          unit: ':km',
        }),
        author: {
          familyName: 'family name',
          givenName: 'given name',
          description: 'product author',
          avatarImage: new AvatarImage({ thumb: new Image({ url: 'https://placehold.it/40x40' }) }),
          profileURL: `#profile${Math.random(10)}`, // eslint-disable-line no-magic-numbers
        },
      }),
    }
  )
);

const generateListings = (arrayLength) => {
  const titleDraft = 'Cisco SF300-48 SRW248G4-K9-NA 10/100 Managed Switch 48 Port';
  const titleDraftLength = titleDraft.length;
  const listings = new Array(arrayLength);

  for (let i = 0; i < arrayLength; i++) {
    const title = titleDraft.substring(0, Math.random() * titleDraftLength);
    listings[i] = listingCardTemplate(title);
  }

  return listings;
};


storiesOf('Search results')
  .add(`ListingCardPanel: ${LISTINGS_COUNT} items`, () => {
    const panel = r(ListingCardPanel, {}, generateListings(LISTINGS_COUNT));

    specs(() => describe('ListingCardPanel', () => {
      it(`Should display ${LISTINGS_COUNT} ListingCards`, () => {
        const mounted = mount(panel);
        expect(mounted.find('.ListingCard')).to.have.length(LISTINGS_COUNT);
      });
    }));

    return r(storify(panel, containerStyle));
  });
