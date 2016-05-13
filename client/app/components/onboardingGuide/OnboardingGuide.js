import React, { PropTypes } from 'react';
import r from 'r-dom';
import _ from 'lodash';

import GuideStatusPage from './GuideStatusPage';
import GuideSloganAndDescriptionPage from './GuideSloganAndDescriptionPage';
import GuideCoverPhotoPage from './GuideCoverPhotoPage';
import GuideFilterPage from './GuideFilterPage';
import GuidePaypalPage from './GuidePaypalPage';
import GuideListingPage from './GuideListingPage';
import GuideInvitationPage from './GuideInvitationPage';

const { shape, func, object, string, objectOf, arrayOf, bool, oneOf } = PropTypes;

// Select child component (page/view) to be rendered
// Returns object (including child component) based on props.data & nextStep
const selectChild = function selectChild(data, nextStep) {
  const { path, onboarding_data, translations } = data;
  const pageData = (path.length > 0) ?
    _.find(onboarding_data, (pd) => pd.sub_path === path.substring(1)) :
    {};
  const commonTranslations = { back_to_todo: translations.back_to_todo };

  switch (path) {
    case '/slogan_and_description':
      return { Page: GuideSloganAndDescriptionPage,
                pageData,
                translations: Object.assign({},
                  commonTranslations,
                  translations.slogan_and_description),
             };
    case '/cover_photo':
      return { Page: GuideCoverPhotoPage,
                pageData,
                translations: Object.assign({},
                  commonTranslations,
                  translations.cover_photo),
             };
    case '/filter':
      return { Page: GuideFilterPage,
                pageData,
                translations: Object.assign({},
                  commonTranslations,
                  translations.filter),
             };
    case '/paypal':
      return { Page: GuidePaypalPage,
                pageData,
                translations: Object.assign({},
                  commonTranslations,
                  translations.paypal),
             };
    case '/listing':
      return { Page: GuideListingPage,
                pageData,
                translations: Object.assign({},
                  commonTranslations,
                  translations.listing),
             };
    case '/invitation':
      return { Page: GuideInvitationPage,
                pageData,
                translations: Object.assign({},
                  commonTranslations,
                  translations.invitation),
             };
    default:
      return { Page: GuideStatusPage,
                onboarding_data,
                translations: Object.assign({},
                  commonTranslations,
                  translations.status_page),
                nextStep,
             };
  }
};

// Get curried function translate page related translations
const translate = function translate(translations) {
  return function curriedTranslate(translationKey) {
    return translations[translationKey];
  };
};

// Get link and title of next recommended onboarding step
const nextStep = function nextStep(data, translateFunc) {
  const nextStepData = data.find(function(step) {
    return !step.complete;
  });

  if (nextStepData) {
    return {
      title: translateFunc(nextStepData.step),
      link: nextStepData.sub_path,
    };
  } else {
    return null;
  }
};

// getPaths: initial path containing given pathFragment & relative (deeper) path
const getPaths = function getPaths(props, pathFragment) {
  const pathParts = props.data.original_path.split(pathFragment);
  const initialPath = pathParts[0] + pathFragment;
  return { initialPath, componentSubPath: pathParts[1] };
};

class OnboardingGuide extends React.Component {

  constructor(props, context) {
    super(props, context);

    this.setPushState = this.setPushState.bind(this);
    this.handlePopstate = this.handlePopstate.bind(this);
    this.handlePageChange = this.handlePageChange.bind(this);

    const paths = getPaths(props, 'getting_started_guide');
    this.initialPath = paths.initialPath;
    this.componentSubPath = paths.componentSubPath;

    // Figure out the next step. I.e. what is the action we recommend for admins
    this.nextStep = nextStep(this.props.data.onboarding_data,
                             translate(this.props.data.translations.next_step));

    // Add current path to window.history. Initially it contains null as a state
    this.setPushState(
      { path: this.componentSubPath },
      this.componentSubPath,
      this.componentSubPath);
  }

  componentDidMount() {
    window.addEventListener('popstate', this.handlePopstate);
  }

  componentWillUpdate(nextProps) {
    // Back button clicks should not be saved with history.pushState
    if (nextProps.data.pathHistoryForward) {
      const path = nextProps.data.path;
      this.setPushState({ path }, path, path);
    }
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handlePopstate);
  }

  setPushState(state, title, path) {
    // React has an internal variable 'canUseDOM', which we emulate here.
    const canUseDOM = !!(typeof window !== 'undefined' &&
                          window.document &&
                          window.document.createElement);
    const canUsePushState = !!(typeof history !== 'undefined' &&
                                history.pushState);

    if (canUseDOM && canUsePushState) {
      window.history.pushState(state, title, `${this.initialPath}${path}`);
    }
  }

  handlePopstate(event) {
    if (event.state != null && event.state.path != null) {
      this.props.actions.updateGuidePage(event.state.path, false);
    } else if (event.state == null && typeof this.props.data.pathHistoryForward !== 'undefined') {
      // null state means that page component's root path is reached and
      // previous page is actually on Rails side - i.e. one step further
      // Safari fix: if pathHistoryForward is not defined, its initial page load
      window.history.back();
    }
  }

  handlePageChange(path) {
    this.props.actions.updateGuidePage(path, true);
  }

  render() {
    const { Page, translations, ...opts } = selectChild(this.props.data, this.nextStep);
    return r(Page, {
      changePage: this.handlePageChange,
      initialPath: this.initialPath,
      name: this.props.data.name,
      infoIcon: this.props.data.info_icon,
      t: translate(translations),
      ...opts,
    });
  }
}

OnboardingGuide.propTypes = {
  actions: PropTypes.shape({
    updateGuidePage: PropTypes.func.isRequired,
  }).isRequired,
  railsContext: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  data: PropTypes.shape({
    path: PropTypes.string.isRequired,
    original_path: PropTypes.string.isRequired,
    pathHistoryForward: PropTypes.bool,
    name: PropTypes.string.isRequired,
    info_icon: PropTypes.string.isRequired,
    translations: PropTypes.object.isRequired,
    onboarding_data: arrayOf(
      shape({
        step: oneOf([
          'slogan_and_description',
          'cover_photo',
          'filter',
          'paypal',
          'listing',
          'invitation',
          'all_done',
        ]).isRequired,
        info_image: string,
        cta: string.isRequired,
        alternative_cta: string,
        complete: bool.isRequired,
      }).isRequired
    ).isRequired,
  }).isRequired,
};

export default OnboardingGuide;
