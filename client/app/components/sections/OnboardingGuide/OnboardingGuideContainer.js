import { PropTypes } from 'react';
import r from 'r-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import OnboardingGuide from './OnboardingGuide';

import * as OnboardingGuideActions from '../../../actions/OnboardingGuideActions';

import * as ownPropTypes from '../../../utils/PropTypes';

const OnbardingGuideContainer = ({ actions, data, marketplaceContext, routes }) =>
        r(OnboardingGuide, { actions, data, marketplaceContext, routes });

const { shape, func } = PropTypes;

OnbardingGuideContainer.propTypes = {
  actions: shape({
    updateGuidePage: func.isRequired,
  }).isRequired,
  marketplaceContext: ownPropTypes.marketplaceContext,
  routes: ownPropTypes.routes,
};

const mapStateToProps = function mapStateToProps(state) {
  return {
    data: state.onboarding_guide_page,
    marketplaceContext: state.marketplaceContext,
    routes: state.routes,
  };
};

const mapDispatchToProps = function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(OnboardingGuideActions, dispatch) };
};

export default connect(mapStateToProps, mapDispatchToProps)(OnbardingGuideContainer);
