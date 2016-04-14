import React from 'react';

const GuideFilterPage = (props) => {
  console.log('filter props', props);

  return (
    <div className="container">
      <h2>{ props.t('title') }</h2>
      <p>
        { props.t('description_p1') }
      </p>
      <p>
        { props.t('description_p2') }
      </p>
      <button>{ props.t('add_fields_and filters') }</button>
      <p>
        { props.t('advice') }
      </p>
    </div>
  );
};

export default GuideFilterPage;