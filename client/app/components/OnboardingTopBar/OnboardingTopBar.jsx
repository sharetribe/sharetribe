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
        link: this.props.guide_root + '/slogan_and_description',
      };
    } else if (!this.props.status.cover_photo) {
      return {
        title: 'Upload cover photo',
        link: this.props.guide_root + '/cover_photo',
      };
    } else if (!this.props.status.filter) {
      return {
        title: 'Add Fields & Filters',
        link: this.props.guide_root + '/filter',
      };
    } else if (!this.props.status.paypal) {
      return {
        title: 'Accept payments',
        link: this.props.guide_root + '/paypal',
      };
    } else if (!this.props.status.listing) {
      return {
        title: 'Add a listing',
        link: this.props.guide_root + '/listing',
      };
    } else if (!this.props.status.invitation) {
      return {
        title: 'Invite users',
        link: this.props.guide_root + '/invitation',
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
  guide_root: PropTypes.string,
};

export default OnboardingTopBar;
