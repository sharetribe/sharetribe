import React, { PropTypes } from 'react';


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
        status: PropTypes.bool.isRequired,
      }).isRequired).isRequired,
    }).isRequired,
  };


  constructor(props, context) {
    super(props, context);

  }


  render() {
    return (
      <div>testing</div>
    );
  }
}

