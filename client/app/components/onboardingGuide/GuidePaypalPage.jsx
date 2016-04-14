import React from 'react';

const GuidePaypalPage = (props) => {
  console.log('paypal props', props);

  return (
    <div className="container">
      <h2>{ props.t('title') }</h2>
      <p>
        { props.t('description_p1') }
      </p>
      <p>
        { props.t('description_p2') }
      </p>
      <button>{ props.t('setup_payments') }</button>
      <p>
        { props.t('advice') }
      </p>
    </div>
  );
};

export default GuidePaypalPage;