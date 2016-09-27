import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import Immutable from 'immutable';
import styleVariables from '../../../assets/styles/variables';

import ListingCard from '../../composites/ListingCard/ListingCard';
import ListingCardPanel from '../../composites/ListingCardPanel/ListingCardPanel';

import css from './SearchPage.css';

const DEFAULT_CONTEXT = {
  marketplace_color1: styleVariables['--customColorFallback'],
};

const listingsByIds = (listings, ids) =>
  ids.map((id) => listings.get(id));

class SearchPage extends Component {

  constructor(props, context) {
    super(props, context);
    this.listingProps = this.listingProps.bind(this);

    this.listings = listingsByIds(props.searchPage.listings, props.searchPage.currentPage) || [];
  }

  listingProps(listing, color) {
    return {
      key: `card_${listing.id}`,
      color,
      listing,
    };
  }

  render() {
    const { marketplace_color1: marketplaceColor1 } = { ...DEFAULT_CONTEXT, ...this.props.marketplace };
    return div({ className: css.searchPage }, [
      r(ListingCardPanel,
        { className: css.listingContainer },
        this.listings.map((listing) =>
          r(ListingCard, this.listingProps(listing, marketplaceColor1))
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

const { instanceOf, string } = PropTypes;

SearchPage.propTypes = {
  searchPage: instanceOf(SearchPageModel).isRequired,
  marketplace: PropTypes.shape({
    marketplaceColor1: string,
    location: string,
  }),
};

export default SearchPage;
