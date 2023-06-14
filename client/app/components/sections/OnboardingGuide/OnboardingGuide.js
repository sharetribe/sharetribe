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

import { canUseDOM, canUsePushState } from '../../../utils/featureDetection';
import { routes, marketplaceContext } from '../../../utils/PropTypes';

// Select child component (page/view) to be rendered
// Returns object (including child component) based on props.data
const selectChild = function selectChild(data) {
  const { page, onboarding_data } = data;
  const pageData = _.find(onboarding_data, (pd) => pd.step === page) || {};

  switch (page) {
    case 'slogan_and_description':
      return { Page: GuideSloganAndDescriptionPage, pageData };
    case 'cover_photo':
      return { Page: GuideCoverPhotoPage, pageData };
    case 'filter':
      return { Page: GuideFilterPage, pageData };
    case 'payment':
      return { Page: GuidePaypalPage, pageData };
    case 'listing':
      return { Page: GuideListingPage, pageData };
    case 'invitation':
      return { Page: GuideInvitationPage, pageData };
    default:
      return { Page: GuideStatusPage, onboarding_data };
  }
};

const setPushState = function setPushState(state, title, path) {
  if (canUseDOM && canUsePushState) {
    window.history.pushState(state, title, path);
  }
};

class OnboardingGuide extends React.Component {

  constructor(props, context) {
    super(props, context);

    this.handlePopstate = this.handlePopstate.bind(this);
    this.handlePageChange = this.handlePageChange.bind(this);

    // Add current path to window.history. Initially it contains null as a state
    const path = this.props.marketplaceContext.pathname;
    const page = this.props.data.page;
    setPushState({ path, page }, path, path);
  }

  componentDidMount() {
    window.addEventListener('popstate', this.handlePopstate);
  }

  componentWillUpdate(nextProps) {
    // Back button clicks should not be saved with history.pushState
    if (nextProps.data.pathHistoryForward) {
      const path = nextProps.data.path;
      const page = nextProps.data.page;
      setPushState({ path, page }, path, path);
    }
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handlePopstate);
  }

  handlePopstate(event) {
    if (event.state != null && event.state.path != null) {
      this.props.actions.updateGuidePage(event.state.page, event.state.path, false);
    } else if (event.state == null && typeof this.props.data.pathHistoryForward !== 'undefined') {
      // null state means that page component's root path is reached and
      // previous page is actually on Rails side - i.e. one step further
      // Safari fix: if pathHistoryForward is not defined, its initial page load
      window.history.back();
    }
  }

  handlePageChange(page, path) {
    this.props.actions.updateGuidePage(page, path, true);
  }

  render() {
    const { Page, ...opts } = selectChild(this.props.data);
    return r(Page, {
      changePage: this.handlePageChange,
      name: this.props.data.name,
      infoIcon: this.props.data.info_icon,
      routes: this.props.routes,
      ...opts,
    });
  }
}

const { shape, string, arrayOf, bool, oneOf, func, object } = PropTypes;

OnboardingGuide.propTypes = {
  actions: shape({
    updateGuidePage: func.isRequired,
  }).isRequired,
  marketplaceContext,
  routes,
  data: shape({
    page: string.isRequired,
    pathHistoryForward: bool,
    name: string.isRequired,
    info_icon: string.isRequired,
    onboarding_data: arrayOf(
      shape({
        step: oneOf([
          'slogan_and_description',
          'cover_photo',
          'filter',
          'payment',
          'listing',
          'invitation',
          'all_done',
        ]).isRequired,
        complete: bool.isRequired,
        additional_info: object,
      }).isRequired
    ).isRequired,
  }).isRequired,
};

export default OnboardingGuide;
