import React from 'react';

const GuideCoverPhotoPage = (props) => {
  console.log('cover props', props);

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

export default GuideCoverPhotoPage;