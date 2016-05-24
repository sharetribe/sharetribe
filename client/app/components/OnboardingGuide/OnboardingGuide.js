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
import { t } from '../../utils/i18n';
import { Routes } from '../../utils/routes';

const { shape, string, arrayOf, bool, oneOf, func, object } = PropTypes;

// Select child component (page/view) to be rendered
// Returns object (including child component) based on props.data & nextStep
const selectChild = function selectChild(data, nextStep) {
  const { path, onboarding_data } = data;
  const pageData = _.find(onboarding_data, (pd) => pd.sub_path === path) || {};

  switch (path) {
    case 'slogan_and_description':
      return { Page: GuideSloganAndDescriptionPage, pageData };
    case 'cover_photo':
      return { Page: GuideCoverPhotoPage, pageData };
    case 'filter':
      return { Page: GuideFilterPage, pageData };
    case 'paypal':
      return { Page: GuidePaypalPage, pageData };
    case 'listing':
      return { Page: GuideListingPage, pageData };
    case 'invitation':
      return { Page: GuideInvitationPage, pageData };
    default:
      return { Page: GuideStatusPage, onboarding_data, nextStep };
  }
};

// Get link and title of next recommended onboarding step
const nextStep = function nextStep(data) {
  const nextStepData = data.find((step) => !step.complete);

  const titles = {
    slogan_and_description: 'web.admin.onboarding.guide.next_step.slogan_and_description',
    cover_photo: 'web.admin.onboarding.guide.next_step.cover_photo',
    filter: 'web.admin.onboarding.guide.next_step.filter',
    paypal: 'web.admin.onboarding.guide.next_step.paypal',
    listing: 'web.admin.onboarding.guide.next_step.listing',
    invitation: 'web.admin.onboarding.guide.next_step.invitation',
  };

  if (nextStepData) {
    return {
      title: t(titles[nextStepData.step]),
      link: nextStepData.sub_path,
    };
  } else {
    return null;
  }
};

const guideRoot = Routes.admin_getting_started_guide_path();

class OnboardingGuide extends React.Component {

  constructor(props, context) {
    super(props, context);

    this.setPushState = this.setPushState.bind(this);
    this.handlePopstate = this.handlePopstate.bind(this);
    this.handlePageChange = this.handlePageChange.bind(this);

    // Figure out the next step. I.e. what is the action we recommend for admins
    this.nextStep = nextStep(this.props.data.onboarding_data);

    // Add current path to window.history. Initially it contains null as a state
    const componentSubPath = this.props.railsContext.pathname.replace(guideRoot, '');
    this.setPushState(
      { path: componentSubPath },
      componentSubPath,
      componentSubPath);

    this.props.data.path = componentSubPath;
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
      window.history.pushState(state, title, `${guideRoot}${path}`);
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
    const { Page, ...opts } = selectChild(this.props.data, this.nextStep);
    return r(Page, {
      changePage: this.handlePageChange,
      name: this.props.data.name,
      infoIcon: this.props.data.info_icon,
      ...opts,
    });
  }
}

OnboardingGuide.propTypes = {
  actions: shape({
    updateGuidePage: func.isRequired,
  }).isRequired,
  railsContext: object.isRequired, // eslint-disable-line react/forbid-prop-types
  data: shape({
    pathHistoryForward: bool,
    name: string.isRequired,
    info_icon: string.isRequired,
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
        cta: string.isRequired,
        complete: bool.isRequired,
        additional_info: object
      }).isRequired
    ).isRequired,
  }).isRequired,
};

export default OnboardingGuide;
