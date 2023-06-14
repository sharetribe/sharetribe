import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import Immutable from 'immutable';
import classNames from 'classnames';
import styleVariables from '../../../assets/styles/variables';
import { routes as routesProp } from '../../../utils/PropTypes';

import Topbar from '../../sections/Topbar/Topbar';
import ListingCard from '../../composites/ListingCard/ListingCard';
import ListingCardPanel from '../../composites/ListingCardPanel/ListingCardPanel';
import Branding from '../../composites/Branding/Branding';
import FlashNotification from '../../composites/FlashNotification/FlashNotification';
import NoResults from '../../composites/NoResults/NoResults';

import css from './SearchPage.css';

const DEFAULT_CONTEXT = {
  marketplace_color1: styleVariables['--customColorFallback'],
};

const listingsByIds = (listings, ids) =>
  ids.map((id) => listings.get(id));

class SearchPage extends Component {

  constructor(props, context) {
    super(props, context);
    this.listings = listingsByIds(props.searchPage.listings, props.searchPage.currentPage) || new Immutable.List();
    this.listingProps = this.listingProps.bind(this);

    this.totalPages = Math.ceil(this.props.searchPage.state.get('total') / this.props.searchPage.state.get('pageSize'));
  }

  listingProps(listing, color, loggedInUsername) {
    const listingKey = listing.id.toString();
    return {
      key: `card_${listingKey}`,
      color,
      listing,
      loggedInUserIsAuthor: loggedInUsername === listing.getIn(['author', 'username']),
    };
  }

  render() {
    const { marketplace_color1: marketplaceColor1, displayBrandingInfo, linkToSharetribe } = { ...DEFAULT_CONTEXT, ...this.props.marketplace };
    const displayBranding = this.props.marketplace && displayBrandingInfo && linkToSharetribe;

    const searchResults = div(
      {
        className: classNames('SearchPage_main', css.main),
      },
      [
        r(ListingCardPanel,
          {
            className: css.listingContainer,
            currentPage: this.props.searchPage.state.get('page'),
            totalPages: this.totalPages,
            location: this.props.marketplace.location,
            pageParam: 'page',
          },
          this.listings.map((listing) =>
            r(ListingCard, this.listingProps(listing, marketplaceColor1, this.props.user.loggedInUsername))
          )
        ),
      ]);
    const noResults = r(NoResults, {
      className: classNames('SearchPage_main', css.empty),
    });

    return div({ className: classNames('SearchPage', css.SearchPage) }, [
      r(Topbar, {
        ...this.props.topbar,
        routes: this.props.routes,
      }),
      this.listings.size > 0 ? searchResults : noResults,
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
  user: shape({
    loggedInUsername: string,
    isAdmin: bool,
  }),
};

export default SearchPage;
