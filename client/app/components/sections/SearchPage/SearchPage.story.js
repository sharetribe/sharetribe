import r, { div, h1, h2, p } from 'r-dom';
import { toFixedNumber } from '../../../utils/numbers';
import ListingCard from '../../composites/ListingCard/ListingCard';
import ListingCardPanel from '../../composites/ListingCardPanel/ListingCardPanel';
import css from './SearchPage.story.css';

const { storiesOf } = storybookFacade;
const LISTINGS_COUNT = 7;

const listingCardTemplate = (title, perUnit, price, distance) => (
  r(ListingCard, Object.assign({},
    {
      id: 'iuttei7538746tr',
      title,
      listingURL: 'http://marketplace.com/listing/342iu4',
      imageURL: 'https://placehold.it/408x408',
      image2xURL: 'https://placehold.it/816x816',
      noImageText: 'No picture',
      avatarURL: 'https://placehold.it/40x40',
      profileURL: `#profile${Math.random(10)}`,  // eslint-disable-line no-magic-numbers
      price: price || toFixedNumber(Math.random() * 9999, 2),  // eslint-disable-line no-magic-numbers
      priceUnit: '€',
      per: perUnit || '/ day',
      distance: distance || Math.random() * (20000) + 0.01,  // eslint-disable-line no-magic-numbers
      distanceUnit: 'km',
      color: '#347F9D',
      className: css.listing,
    },
  ))
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
  .add('Summary', () => (
    div(null, [
      h1({ className: css.title }, 'Listings'),
      p({ className: css.description }, 'Search results are shown in grid view using listing cards. They contain square images and the result set is paged.'),
      h2({ className: css.sectionTitle }, 'ListingCard'),
      div({
        className: css.singleListingWrapper,
      }, listingCardTemplate('Listing title', '/ hundred centimeters')),
      h2({ className: css.sectionTitle }, `ListingCardPanel (${LISTINGS_COUNT} listings)`),
      r(ListingCardPanel, null, generateListings(LISTINGS_COUNT)),
    ])
  ));
