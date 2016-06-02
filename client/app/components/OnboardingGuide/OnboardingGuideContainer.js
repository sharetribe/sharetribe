import { PropTypes } from 'react';
import r from 'r-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import OnboardingGuide from './OnboardingGuide';

import * as OnboardingGuideActions from '../../actions/OnboardingGuideActions';

const OnbardingGuideContainer = ({ actions, data, railsContext, routes }) =>
        r(OnboardingGuide, { actions, data, railsContext });

const { shape, func, object } = PropTypes;

OnbardingGuideContainer.propTypes = {
  actions: shape({
    updateGuidePage: func.isRequired,
  }).isRequired,
  railsContext: object.isRequired, // eslint-disable-line react/forbid-prop-types
  routes: object.isRequired
};

function mapStateToProps(state) {
  return {
    data: state.onboarding_guide_page,
    railsContext: state.railsContext,
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(OnboardingGuideActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(OnbardingGuideContainer);
