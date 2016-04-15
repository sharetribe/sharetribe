import React, { PropTypes } from 'react';

import css from './OnboardingTopBar.scss';

const OnboardingTopBar = (props) => {
  function t(translationKey) {
    return props.translations[translationKey];
  }

  function next() {
    if (!props.status.slogan_and_description) {
      return {
        title: 'Add Slogan & Description',
        link: '/admin/effe',
      };
    } else if (!props.status.cover_photo) {
      return {
        title: 'Upload cover photo',
        link: '/admin/effe',
      };
    } else if (!props.status.filter) {
      return {
        title: 'Add Fields & Filters',
        link: '/admin/effe',
      };
    } else if (!props.status.paypal) {
      return {
        title: 'Accept payments',
        link: '/admin/effe',
      };
    } else if (!props.status.listing) {
      return {
        title: 'Add a listing',
        link: '/admin/effe',
      };
    } else if (!props.status.invitation) {
      return {
        title: 'Invite users',
        link: '/admin/effe',
      };
    }
    return null;
  }

  function progress() {
    const steps = Object.keys(props.status).filter((entry) =>
      ['slogan_and_description',
       'cover_photo',
       'filter',
       'paypal',
       'listing',
       'invitation'].includes(entry)).map((key) => [key, props.status[key]]);
    const completed = steps.filter((entry) => entry[1]);
    return 100 * completed.length / steps.length;
  }

  function nextElement() {
    if (next()) {
      return (
        <div className={css.nextContainer}>
          <div className={css.nextLabel}>
            {t('next_step')}:
          </div>
          <a href={next().link} className={css.nextButton}>
            <span>{next().title}</span>
          </a>
        </div>
      );
    }
    return null;
  }

  return (
    <div className={css.topbarContainer}>
      <div className={css.topbar}>
        <div className={css.progressLabel}>
          {t('progress_label')}: <span className={css.progressLabelPercentage}>{progress().toPrecision(2)} %</span>
        </div>
        <div className={css.progressBarBackground}>
          <div className={css.progressBar} style={{ width: `${progress()}%` }} />
        </div>
        {nextElement()}
      </div>
    </div>
  );
};

OnboardingTopBar.propTypes = {
  translations: PropTypes.object,
  status: PropTypes.object,
};

export default OnboardingTopBar;
