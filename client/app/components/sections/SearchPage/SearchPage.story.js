import r, { div, h1, h2, p } from 'r-dom';
import { mount } from 'enzyme';

import { storify } from '../../Styleguide/withProps';
import { formatDistance, formatPrice } from '../../../utils/numbers';

import ListingCard from '../../composites/ListingCard/ListingCard';
import css from './SearchPage.story.css';

const { storiesOf, specs, expect } = storybookFacade;
const containerStyle = { style: { background: 'white' } };


const ListingCardTemplate = (title, perUnit, price, distance) => (
  r(ListingCard, Object.assign({},
    {
      id: 'iuttei7538746tr',
      title,
      listingURL: 'http://marketplace.com/listing/342iu4',
      imageURL: 'https://placehold.it/408x408',
      image2xURL: 'https://placehold.it/816x816',
      noImageText: 'No picture',
      avatarURL: 'https://placehold.it/40x40',
      profileURL: `#profile${Math.random(10)}`,
      price: price || (Math.random() * 9999).toFixed(2),
      priceUnit: '€',
      per: perUnit || '/ day',
      distance: distance || Math.random() * (20000) + 0.01,
      distanceUnit: 'km',
      color: '#347F9D',
      className: css.listing,
    },
  ))
);

const generateListings = () => {
  const titleDraft = 'Cisco SF300-48 SRW248G4-K9-NA 10/100 Managed Switch 48 Port';
  const titleDraftLength = titleDraft.length;
  const listings = new Array(24);
  for (var i = 0; i < listings.length; i++) {
    const title = titleDraft.substring(0, Math.random() * titleDraftLength);
    listings[i] = ListingCardTemplate(title);
  }

  return listings;
}


storiesOf('Search results')
  .add('Summary', () => (
    div({
      className: css.previewPage,
    }, [
      h1({ className: css.title }, 'Listings'),
      p({ className: css.description }, 'Search results are shown in grid view using listing cards. They contain square images and the result set is paged.'),
      h2({ className: css.sectionTitle }, 'ListingCard'),
      div({
        className: css.singleListingWrapper,
      }, ListingCardTemplate('Listing title', '/ hundred centimeters')),
      h2({ className: css.sectionTitle }, 'ListingPage (not ready yet)'),
      div({
        className: css.wrapper,
      }, generateListings()),
    ])
  ));
