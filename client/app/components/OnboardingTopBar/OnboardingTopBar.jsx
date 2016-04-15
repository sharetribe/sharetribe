import React, { PropTypes } from 'react';

import css from './OnboardingTopBar.scss';

class OnboardingTopBar extends React.Component {

  t(translationKey) {
    return this.props.translations[translationKey];
  }

  next() {
    if (!this.props.status.slogan_and_description) {
      return {
        title: 'Add Slogan & Description',
        link: '/admin/effe',
      };
    } else if (!this.props.status.cover_photo) {
      return {
        title: 'Upload cover photo',
        link: '/admin/effe',
      };
    } else if (!this.props.status.filter) {
      return {
        title: 'Add Fields & Filters',
        link: '/admin/effe',
      };
    } else if (!this.props.status.paypal) {
      return {
        title: 'Accept payments',
        link: '/admin/effe',
      };
    } else if (!this.props.status.listing) {
      return {
        title: 'Add a listing',
        link: '/admin/effe',
      };
    } else if (!this.props.status.invitation) {
      return {
        title: 'Invite users',
        link: '/admin/effe',
      };
    }
    return null;
  }

  progress() {
    const steps = Object.keys(this.props.status).filter((entry) =>
      ['slogan_and_description',
       'cover_photo',
       'filter',
       'paypal',
       'listing',
       'invitation'].includes(entry)).map((key) => [key, this.props.status[key]]);
    const completed = steps.filter((entry) => entry[1]);
    return 100 * completed.length / steps.length;
  }

  nextElement() {
    if (this.next()) {
      return (
        <div className={css.nextContainer}>
          <div className={css.nextLabel}>
            {this.t('next_step')}:
          </div>
          <a href={this.next().link} className={css.nextButton}>
            <span>{this.next().title}</span>
          </a>
        </div>
      );
    }
    return null;
  }

  render() {
    return (
      <div className={css.topbarContainer}>
        <div className={css.topbar}>
          <div className={css.progressLabel}>
            {this.t('progress_label')}:
            <span className={css.progressLabelPercentage}>{this.progress().toPrecision(2)} %</span>
          </div>
          <div className={css.progressBarBackground}>
            <div className={css.progressBar} style={{ width: `${this.progress()}%` }} />
          </div>
          {this.nextElement()}
        </div>
      </div>
    );
  }
}

OnboardingTopBar.propTypes = {
  translations: PropTypes.object,
  status: PropTypes.object,
};

export default OnboardingTopBar;
