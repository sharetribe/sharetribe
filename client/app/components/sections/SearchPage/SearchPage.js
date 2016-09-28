import { Component, PropTypes } from 'react';
import r, { div, img, p } from 'r-dom';
import Immutable from 'immutable';

import ListingCard from '../../composites/ListingCard/ListingCard';
import ListingCardPanel from '../../composites/ListingCardPanel/ListingCardPanel';

import css from './SearchPage.css';

const listingsByIds = (listings, ids) =>
  ids.map((id) => listings.get(id));

class SearchPage extends Component {

  constructor(props, context) {
    super(props, context);
    this.listings = listingsByIds(props.searchPage.listings, props.searchPage.currentPage) || [];
    this.listingProps = this.listingProps.bind(this);
  }

  listingProps(listing, color) {
    return {
      key: `card_${listing.get('id')}`,
      color: '#347F9D',
      listing,
    };
  }

  render() {
    return div({ className: css.searchPage }, [
      r(ListingCardPanel,
        { className: css.listingContainer },
        this.listings.map((listing) =>
          r(ListingCard, this.listingProps(listing, this.props.color))
      )),
    ]);
  }
}

export const SearchPageModel = Immutable.Record({
  prevPage: new Immutable.List(),
  currentPage: new Immutable.List(),
  nextPage: new Immutable.List(),
  listings: new Immutable.List(),
});

const { instanceOf } = PropTypes;

SearchPage.propTypes = {
  searchPage: instanceOf(SearchPageModel).isRequired,
};

export default SearchPage;
