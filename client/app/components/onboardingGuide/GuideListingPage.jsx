import React from 'react';

const GuideListingPage = (props) => {
  console.log('listing props', props);

  return (
    <div className="container">
      <h2>{ props.t('title') }</h2>
      <p>
        { props.t('description') }
      </p>
      <button>{ props.t('post_your_first_listing') }</button>
      <p>
        { props.t('advice') }
      </p>
    </div>
  );
};

export default GuideListingPage;