import React from 'react';

const GuideInvitationPage = (props) => {
  console.log('invitations props', props);

  return (
    <div className="container">
      <h2>{ props.t('title') }</h2>
      <p>
        { props.t('description') }
      </p>
      <button>{ props.t('invite_users') }</button>
      <p>
        { props.t('advice') }
      </p>
    </div>
  );
};

export default GuideInvitationPage;