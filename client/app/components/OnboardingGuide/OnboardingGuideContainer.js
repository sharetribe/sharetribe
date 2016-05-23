import { PropTypes } from 'react';
import r from 'r-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import OnboardingGuide from './OnboardingGuide';

import * as OnboardingGuideActions from '../../actions/OnboardingGuideActions';

const OnbardingGuideContainer = ({ actions, data, railsContext }) =>
        r(OnboardingGuide, { actions, data, railsContext });

OnbardingGuideContainer.propTypes = {
  actions: PropTypes.shape({
    updateGuidePage: PropTypes.func.isRequired,
  }).isRequired,
  railsContext: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
};

const mapStateToProps = function mapStateToProps(state) {
  return {
    data: state.onboarding_guide_page,
    railsContext: state.railsContext,
  };
};

const mapDispatchToProps = function mapDispatchToProps(dispatch) {
  return { actions: bindActionCreators(OnboardingGuideActions, dispatch) };
};

export default connect(mapStateToProps, mapDispatchToProps)(OnbardingGuideContainer);
