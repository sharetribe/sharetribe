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

function mapStateToProps(state) {
  return {
    searchPage: state.searchPage,
    routes: state.routes,
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(SearchPageActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(SearchPageContainer);
