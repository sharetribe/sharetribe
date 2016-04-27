import React, { PropTypes } from 'react';
import { translate } from '../../utils/i18nUtils';

import css from './OnboardingTopBar.scss';

function next(nextStep, guideRoot, t) {
  return nextStep ? {
    title: t(nextStep),
    link: `${guideRoot}/${nextStep}`,
  } : null;
}

class OnboardingTopBar extends React.Component {

  nextElement() {
    const t = translate(this.props.translations);
    const nextStep = next(this.props.nextStep, this.props.guideRoot, t);
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
            <span className={css.progressLabelPercentage}>{currentProgress.toPrecision(2)} %</span>
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
  guideRoot: PropTypes.string.isRequired,
  progress: PropTypes.number.isRequired,
  nextStep: PropTypes.string.isRequired,
};

export default OnboardingTopBar;
