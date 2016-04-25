import React, { PropTypes } from 'react';

import GuideStatusPage from './GuideStatusPage';
import GuideSloganAndDescriptionPage from './GuideSloganAndDescriptionPage';
import GuideCoverPhotoPage from './GuideCoverPhotoPage';
import GuideFilterPage from './GuideFilterPage';
import GuidePaypalPage from './GuidePaypalPage';
import GuideListingPage from './GuideListingPage';
import GuideInvitationPage from './GuideInvitationPage';

export default class OnboardingGuide extends React.Component {

  static propTypes = {
    actions: PropTypes.shape({
      updateGuidePage: PropTypes.func.isRequired,
    }).isRequired,
    railsContext: PropTypes.object.isRequired,
    data: PropTypes.shape({
      path: PropTypes.string.isRequired,
      pathHistoryForward: PropTypes.bool,
      name: PropTypes.string.isRequired,
      translations: PropTypes.object.isRequired,
      onboarding_data: PropTypes.objectOf(PropTypes.shape({
        infoImage: PropTypes.string.isRequired,
        link: PropTypes.string.isRequired,
        complete: PropTypes.bool.isRequired,
      }).isRequired).isRequired,
    }).isRequired,
  };


  constructor(props, context) {
    super(props, context);

    this.handlePageChange = this.handlePageChange.bind(this);

    const paths = getPaths(props, 'getting_started_guide');
    this.initialPath = paths.initialPath;
    this.componentSubPath = paths.componentSubPath;

    // Figure out the next step. I.e. what is the action we recommend for admins
    this.nextStep = nextStep(this.props.data.onboarding_data,
      translate(this.props.data.translations.next_step),
      this.initialPath);

  }

  handlePageChange(path) {
    this.props.actions.updateGuidePage(path, true);
  }

  render() {
    const { Page, translations, ...opts } = selectChild(this.props.data, this.nextStep);
    return (
      <Page
        changePage={this.handlePageChange}
        initialPath={this.initialPath}
        name={this.props.data.name}
        t={translate(translations)}
        {...opts}
      />
    );
  }
}

// Select child component (page/view) to be rendered
// Returns object (including child component) based on props.data & nextStep
const selectChild = function selectChild(data, nextStep) {
  const { path, onboarding_data, translations } = data;
  const pageData = (path.length > 0) ? onboarding_data[path.substring(1)] : {};
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
const nextStep = function nextStep(data, translateFunc, initialPath) {
  const keys = Object.keys(data);
  for (let i = 0; i < keys.length; i++) {
    const step = keys[i];
    if (!data[step].complete) {
      return {
        title: translateFunc(step),
        link: step,
      };
    }
  }
  return false;
};

// getPaths: initial path containing given pathFragment & relative (deeper) path
const getPaths = function getPaths(props, pathFragment) {
  const pathParts = props.railsContext.location.split(pathFragment);
  const initialPath = pathParts[0] + pathFragment;
  return { initialPath, componentSubPath: pathParts[1] };
};
