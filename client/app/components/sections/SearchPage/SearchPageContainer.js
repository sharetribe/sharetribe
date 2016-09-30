import { PropTypes } from 'react';
import r from 'r-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import * as SearchPageActions from '../../../actions/SearchPageActions';
import * as ownPropTypes from '../../../utils/PropTypes';
import SearchPage from './SearchPage';

const SearchPageContainer = ({ actions, routes, ...rest }) =>
        r(SearchPage, { actions, routes, ...rest });

const { shape, func } = PropTypes;

SearchPageContainer.propTypes = {
  actions: shape({
    updateCurrentPage: func.isRequired,
  }).isRequired,
  routes: ownPropTypes.routes,
};

const listingsWithAuthors = (listings, profiles) =>
  listings.map((listing) => {
    const author = profiles.get(listing.authorId);
    return listing.set('author', author);
  });

const mapStateToProps = function mapStateToProps(state) {
  const l = listingsWithAuthors(state.listings, state.profiles);
  return {
    searchPage: state.searchPage.set('listings', l),
    marketplace: state.marketplace,
    routes: state.routes,
  };
};

const mapDispatchToProps = function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(SearchPageActions, dispatch) };
};

export default connect(mapStateToProps, mapDispatchToProps)(SearchPageContainer);
