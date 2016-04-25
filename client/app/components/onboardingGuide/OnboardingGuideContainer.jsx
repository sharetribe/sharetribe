import React, { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import OnboardingGuide from './OnboardingGuide';

import * as OnboardingGuideActions from '../../actions/OnboardingGuideActions';

const OnbardingGuideContainer = ({ actions, data, railsContext }) =>
  (<OnboardingGuide {...{ actions, data, railsContext }} />);


OnbardingGuideContainer.propTypes = {
  actions: PropTypes.shape({
    updateGuidePage: PropTypes.func.isRequired,
  }).isRequired,
  railsContext: PropTypes.object.isRequired,
  data: PropTypes.shape({
    path: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    translations: PropTypes.object.isRequired,
    onboarding_data: PropTypes.objectOf(PropTypes.shape({
      infoImage: PropTypes.string.isRequired,
      link: PropTypes.string.isRequired,
      status: PropTypes.bool.isRequired,
    }).isRequired).isRequired,
  }).isRequired,
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
