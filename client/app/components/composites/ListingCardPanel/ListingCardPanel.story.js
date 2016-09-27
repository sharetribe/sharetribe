import r from 'r-dom';
import { mount } from 'enzyme';

import { storify } from '../../Styleguide/withProps';
import { toFixedNumber } from '../../../utils/numbers';

import ListingCardPanel from '../ListingCardPanel/ListingCardPanel';
import ListingCard from '../ListingCard/ListingCard';

const LISTINGS_COUNT = 24;

const { storiesOf, specs, expect } = storybookFacade;
const containerStyle = { style: { background: 'white' } };


const listingCardTemplate = (title, perUnit, price, distance) => (
  r(ListingCard,
    {
      id: 'iuttei7538746tr',
      title,
      listingURL: 'http://marketplace.com/listing/342iu4',
      imageURL: 'https://placehold.it/408x408',
      image2xURL: 'https://placehold.it/816x816',
      noImageText: 'No picture',
      avatarURL: 'https://placehold.it/40x40',
      profileURL: `#profile${Math.random(10)}`, // eslint-disable-line no-magic-numbers
      price: price || toFixedNumber(Math.random() * 9999, 2), // eslint-disable-line no-magic-numbers
      priceUnit: '€',
      per: perUnit || '/ day',
      distance: distance || Math.random() * (20000) + 0.01, // eslint-disable-line no-magic-numbers
      distanceUnit: 'km',
      color: '#347F9D',
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
