import React from 'react';

const GuideSloganAndDescriptionPage = (props) => {
  console.log('slogan props', props);

  return (
    <div className="container">
      <h2>{ props.t('title') }</h2>
      <p>
        { props.t('description') }
      </p>
      <button>{ props.t('add_your_own') }</button>
      <p>
        { props.t('advice_p1') }
      </p>
      <p>
        { props.t('advice_p2') }
      </p>

    </div>
  );
};

export default GuideSloganAndDescriptionPage;