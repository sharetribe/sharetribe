import React, {PropTypes} from 'react';

import GuideStatusPage from './GuideStatusPage';
import GuideSloganAndDescriptionPage from './GuideSloganAndDescriptionPage';
import GuideCoverPhotoPage from './GuideCoverPhotoPage';
import GuideFilterPage from './GuideFilterPage';
import GuidePaypalPage from './GuidePaypalPage';
import GuideListingPage from './GuideListingPage';
import GuideInvitationPage from './GuideInvitationPage';

export default class OnboardingGuide extends React.Component {

  static propTypes = {
    actions: PropTypes.object.isRequired,
    data: PropTypes.object.isRequired,
    railsContext: PropTypes.object.isRequired,
  };

  componentDidMount() {
    window.addEventListener('popstate', this.handlePopstate);
  }

  componentWillUnmount() {
    window.removeEventListener('popstate', this.handlePopstate);
  }

  constructor(props, context) {
    super(props, context);

    this.getPathsFromRailsContext = this.getPathsFromRailsContext.bind(this);
    this.setPushState = this.setPushState.bind(this);
    this.handlePopstate = this.handlePopstate.bind(this);
    this.handlePageChange = this.handlePageChange.bind(this);
    this.selectChild = this.selectChild.bind(this);

    const { initialPath, componentRelativePath } = this.getPathsFromRailsContext(props);
    this.initialPath = initialPath;
    this.componentRelativePath = componentRelativePath;

    // Add current path to window.history. It is initially containing null as a state
    this.setPushState(
      { path: componentRelativePath },
      componentRelativePath,
      componentRelativePath);
  }

  getPathsFromRailsContext(props) {
    const pathParts = props.railsContext.location.split('getting_started_guide');
    const initialPath = pathParts[0] + "getting_started_guide";

    if(props.data.lastActionType == null) {
      const componentRelativePath = (pathParts[1] == "") ? "" : pathParts[1];
      return { initialPath, componentRelativePath };
    }
    return { initialPath, componentRelativePath: props.data.path };
  }

  setPushState(state, title, path) {
    // React has an internal variable 'canUseDOM', which we emulate here.
    const canUseDOM = !!( typeof window !== 'undefined' &&
                          window.document &&
                          window.document.createElement );
    const canUsePushState = !!( typeof history !== 'undefined' &&
                                history.pushState );

    if(canUseDOM && canUsePushState) {
      window.history.pushState(state, title, this.initialPath + path);
    }
  }

  handlePopstate(event) {
    if(event.state != null && event.state.path != null) {
      this.handlePageChange(event.state.path);
    } else if(event.state == null) {
      // null state means that page component's root path is reached and
      // previous page is actually on Rails side - i.e. one step further
      window.history.back();
    }
  }

  handlePageChange(path) {
    this.props.actions.updateGuidePage(path);
  }

  translate(translations) {
    return function(translationKey) {
      return translations[translationKey];
    }
  }

  selectChild(data) {
    const { path, onboarding_status, translations } = data;
    const status = (path.length > 0) ? onboarding_status[path.substring(1)] : false;

    switch(path) {
      case "/slogan_and_description":
        return  { Page: GuideSloganAndDescriptionPage,
                  status,
                  translations: translations.slogan_and_description
                };
      case "/cover_photo":
        return  { Page: GuideCoverPhotoPage,
                  status,
                  translations: translations.cover_photo
                };
      case "/filter":
        return  { Page: GuideFilterPage,
                  status,
                  translations: translations.filter
                };
      case "/paypal":
        return  { Page: GuidePaypalPage,
                  status,
                  translations: translations.paypal
                };
      case "/listing":
        return  { Page: GuideListingPage,
                  status,
                  translations: translations.listing
                };
      case "/invitation":
        return  { Page: GuideInvitationPage,
                  status,
                  translations: translations.invitation
                };
      default:
        return  { Page: GuideStatusPage,
                  onboarding_status: onboarding_status,
                  translations: translations.status_page
                };
    }
  }

  render() {
    const { Page, translations, ...opts } = this.selectChild(this.props.data);
    return (
      <Page
        changePage={ this.handlePageChange }
        initialPath={ this.initialPath }
        setPushState={ this.setPushState }
        name={ this.props.data.name }
        t={ this.translate(translations) }
        { ...opts } />
    );
  }
};
