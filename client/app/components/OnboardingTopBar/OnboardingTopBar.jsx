import React, { PropTypes } from 'react';
import { translate } from '../../utils/i18nUtils';

import css from './OnboardingTopBar.scss';

function next(nextStep, guideRoot, t) {
  return t(nextStep) ? {
    title: t(nextStep),
    link: `${guideRoot}/${nextStep}`,
  } : null;
}

class OnboardingTopBar extends React.Component {

  nextElement() {
    const t = translate(this.props.translations);
    const nextStep = next(this.props.next_step, this.props.guide_root, t);
    if (nextStep) {
      return (
        <div className={css.nextContainer}>
          <div className={css.nextLabel}>
            {t('next_step')}:
          </div>
          <a href={nextStep.link} className={css.nextButton}>
            <span>{nextStep.title}</span>
          </a>
        </div>
      );
    }
    return null;
  }

  render() {
    const t = translate(this.props.translations);
    const currentProgress = this.props.progress;
    return (
      <div className={css.topbarContainer}>
        <div className={css.topbar}>
          <div className={css.progressLabel}>
            {t('progress_label')}:
            <span className={css.progressLabelPercentage}>{Math.floor(currentProgress)} %</span>
          </div>
          <div className={css.progressBarBackground}>
            <div className={css.progressBar} style={{ width: `${currentProgress}%` }} />
          </div>
          {this.nextElement()}
        </div>
      </div>
    );
  }
}

OnboardingTopBar.propTypes = {
  translations: PropTypes.objectOf(PropTypes.string).isRequired,
  guide_root: PropTypes.string.isRequired,
  progress: PropTypes.number.isRequired,
  next_step: PropTypes.string.isRequired,
};

export default OnboardingTopBar;
