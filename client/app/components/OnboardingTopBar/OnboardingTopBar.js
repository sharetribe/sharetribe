import { Component, PropTypes } from 'react';
import { translate } from '../../utils/i18nUtils';
import { div, span, a } from 'r-dom';

import css from './OnboardingTopBar.scss';

const next = function next(nextStep, guideRoot, t) {
  return t(nextStep) ? {
    title: t(nextStep),
    link: `${guideRoot}/${nextStep}`,
  } : null;
};

class OnboardingTopBar extends Component {

  nextElement() {
    const t = translate(this.props.translations);
    const nextStep = next(this.props.next_step, this.props.guide_root, t);
    if (nextStep) {
      return (
        div({ className: css.nextContainer }, [
          div({ className: css.nextLabel }, t('next_step')),
          a({ href: nextStep.link, className: css.nextButton }, [
            span(nextStep.title),
          ]),
        ])
      );
    }
    return null;
  }

  render() {
    const t = translate(this.props.translations);
    const currentProgress = this.props.progress;
    return div({ className: css.topbarContainer }, [
      div({ className: css.topbar }, [
        a({ className: css.progressLabel, href: this.props.guide_root }, [
          t('progress_label'),
          span({ className: css.progressLabelPercentage },
               `${Math.floor(currentProgress)} %`),
        ]),
        div({ className: css.progressBarBackground }, [
          div({ className: css.progressBar, style: { width: `${currentProgress}%` } }),
        ]),
        this.nextElement(),
      ]),
    ]);
  }
}

OnboardingTopBar.propTypes = {
  translations: PropTypes.objectOf(PropTypes.string).isRequired,
  guide_root: PropTypes.string.isRequired,
  progress: PropTypes.number.isRequired,
  next_step: PropTypes.string.isRequired,
};

export default OnboardingTopBar;
