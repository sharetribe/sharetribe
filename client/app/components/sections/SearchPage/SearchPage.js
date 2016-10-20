import { Component, PropTypes } from 'react';
import r, { div, a } from 'r-dom';
import Immutable from 'immutable';
import styleVariables from '../../../assets/styles/variables';
import { routes as routesProp } from '../../../utils/PropTypes';
import { upsertSearchQueryParam } from '../../../utils/url';

import Topbar from '../../sections/Topbar/Topbar';
import ListingCard from '../../composites/ListingCard/ListingCard';
import ListingCardPanel from '../../composites/ListingCardPanel/ListingCardPanel';
import Branding from '../../composites/Branding/Branding';
import FlashNotification from '../../composites/FlashNotification/FlashNotification';

import css from './SearchPage.css';

const DEFAULT_CONTEXT = {
  marketplace_color1: styleVariables['--customColorFallback'],
};

const listingsByIds = (listings, ids) =>
  ids.map((id) => listings.get(id));

class SearchPage extends Component {

  constructor(props, context) {
    super(props, context);
    this.listings = listingsByIds(props.searchPage.listings, props.searchPage.currentPage) || [];
    this.listingProps = this.listingProps.bind(this);
    this.nextPage = this.nextPage.bind(this);
    this.prevPage = this.prevPage.bind(this);

    this.totalPages = Math.ceil(this.props.searchPage.state.get('total') / this.props.searchPage.state.get('per_page'));
    this.hasNextPage = this.totalPages > this.props.searchPage.state.get('page');
    this.hasPrevPage = this.props.searchPage.state.get('page') > 1;
  }

  nextPage() {
    return this.props.searchPage.state.get('page') + 1;
  }

  prevPage() {
    return this.props.searchPage.state.get('page') - 1;
  }

  setPage(num) {
    return (e) => {
      e.preventDefault();
      const next = this.pageUrl(num);
      window.location = next;
      return false;
    };
  }

  pageUrl(num) {
    const newParams = upsertSearchQueryParam(this.props.marketplace.location, 'page', num);
    const locationBase = this.props.marketplace.location.split('?')[0];
    return `${locationBase}?${newParams}`;
  }

  listingProps(listing, color) {
    const listingKey = listing.id.toString();
    return {
      key: `card_${listingKey}`,
      color,
      listing,
    };
  }

  render() {
    const { marketplace_color1: marketplaceColor1, displayBrandingInfo, linkToSharetribe } = { ...DEFAULT_CONTEXT, ...this.props.marketplace };
    const displayBranding = this.props.marketplace && displayBrandingInfo && linkToSharetribe;
    return div({ className: css.searchPage }, [
      r(Topbar, {
        ...this.props.topbar,
        routes: this.props.routes,
      }),
      r(ListingCardPanel,
        { className: css.listingContainer },
        this.listings.map((listing) =>
          r(ListingCard, this.listingProps(listing, marketplaceColor1))
      )),
      div({}, [
        `${this.props.searchPage.state.get('total')} listings, page ${this.props.searchPage.state.get('page')}/${this.totalPages}`,
        this.hasPrevPage ? a({ onClick: this.setPage(this.prevPage()), href: this.pageUrl(this.prevPage()) }, 'prev') : null,
        this.hasNextPage ? a({ onClick: this.setPage(this.nextPage()), href: this.pageUrl(this.nextPage()) }, 'next') : null,
      ]),
      displayBranding ? r(Branding, { linkToSharetribe }) : null,
      r(FlashNotification, {
        actions: this.props.actions,
        messages: this.props.flashNotifications,
      }),
    ]);
  }
}

export const SearchPageModel = Immutable.Record({
  prevPage: new Immutable.List(),
  currentPage: new Immutable.List(),
  nextPage: new Immutable.List(),
  listings: new Immutable.List(),
  state: new Immutable.Map(),
});

const { bool, func, instanceOf, shape, string } = PropTypes;

SearchPage.propTypes = {
  actions: shape({
    removeFlashNotification: func.isRequired,
  }).isRequired,
  flashNotifications: instanceOf(Immutable.List).isRequired,
  searchPage: instanceOf(SearchPageModel).isRequired,
  marketplace: PropTypes.shape({
    marketplaceColor1: string,
    location: string,
    displayBrandingInfo: bool,
    linkToSharetribe: string,
  }),
  routes: routesProp,
  topbar: shape(Topbar.propTypes).isRequired,
};

export default SearchPage;
