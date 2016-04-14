import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import OnboardingGuide from './OnboardingGuide';

import * as OnboardingGuideActions from '../../actions/OnboardingGuideActions';

const OnbardingGuideContainer = ({ actions, data, railsContext }) => {
  return (
    <OnboardingGuide {...{actions, data, railsContext}} />
  );
}

OnbardingGuideContainer.propTypes = {
  actions: PropTypes.object.isRequired,
  data: PropTypes.object.isRequired,
  railsContext: PropTypes.object.isRequired
};

function mapStateToProps(state) {
  return {
    data: state.onboardingGuidePage,
    railsContext: state.railsContext,
  };
}

function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(OnboardingGuideActions, dispatch) };
}

export default connect(mapStateToProps, mapDispatchToProps)(OnbardingGuideContainer);
