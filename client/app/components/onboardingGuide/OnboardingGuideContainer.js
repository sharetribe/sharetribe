import { PropTypes } from 'react';
import r from 'r-dom';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';

import OnboardingGuide from './OnboardingGuide';

import * as OnboardingGuideActions from '../../actions/OnboardingGuideActions';

const OnbardingGuideContainer = ({ actions, data, railsContext }) =>
        r(OnboardingGuide, { actions, data, railsContext });

const { shape, func, object, string, objectOf, arrayOf, bool } = PropTypes;

OnbardingGuideContainer.propTypes = {
  actions: shape({
    updateGuidePage: func.isRequired,
  }).isRequired,
  railsContext: object.isRequired, // eslint-disable-line react/forbid-prop-types
  data: shape({
    path: string.isRequired,
    original_path: string.isRequired,
    name: string.isRequired,
    info_icon: string.isRequired,
    translations: object.isRequired,
    onboarding_data: objectOf(shape({
      info_image: string,
      cta: string.isRequired,
      alternative_cta: string,
      complete: bool.isRequired,
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
