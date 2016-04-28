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
    original_path: PropTypes.string.isRequired,
    name: PropTypes.string.isRequired,
    info_icon: PropTypes.string.isRequired,
    translations: PropTypes.object.isRequired,
    onboarding_data: PropTypes.objectOf(PropTypes.shape({
      info_image: PropTypes.string,
      link: PropTypes.string.isRequired,
      complete: PropTypes.bool.isRequired,
    }).isRequired).isRequired,
  }).isRequired,
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
