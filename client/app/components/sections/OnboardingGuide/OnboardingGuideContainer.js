import { PropTypes } from 'react';
import r from 'r-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import OnboardingGuide from './OnboardingGuide';

import * as OnboardingGuideActions from '../../../actions/OnboardingGuideActions';

import * as ownPropTypes from '../../../utils/PropTypes';

const OnbardingGuideContainer = ({ actions, data, railsContext, routes }) =>
        r(OnboardingGuide, { actions, data, railsContext, routes });

const { shape, func } = PropTypes;

OnbardingGuideContainer.propTypes = {
  actions: shape({
    updateGuidePage: func.isRequired,
  }).isRequired,
  railsContext: ownPropTypes.railsContext,
  routes: ownPropTypes.routes,
};

function mapStateToProps(state) {
  return {
    data: state.onboarding_guide_page,
    railsContext: state.railsContext,
    routes: state.routes,
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(OnboardingGuideActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(OnbardingGuideContainer);
