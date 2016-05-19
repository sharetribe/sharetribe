import { Component, PropTypes } from 'react';
import { div, span, a } from 'r-dom';
import { t } from '../../utils/i18n';
import { Routes } from '../../utils/routes';

import css from './OnboardingTopBar.css';

const next = function next(nextStep, guideRoot) {
  switch (nextStep) {
    case 'slogan_and_description':
      return {
        title: t('web.admin.onboarding.topbar.slogan_and_description'),
        link: `${guideRoot}/${nextStep}`,
      };
    case 'cover_photo':
      return {
        title: t('web.admin.onboarding.topbar.cover_photo'),
        link: `${guideRoot}/${nextStep}`,
      };
    case 'filter':
      return {
        title: t('web.admin.onboarding.topbar.filter'),
        link: `${guideRoot}/${nextStep}`,
      };
    case 'paypal':
      return {
        title: t('web.admin.onboarding.topbar.paypal'),
        link: `${guideRoot}/${nextStep}`,
      };
    case 'listing':
      return {
        title: t('web.admin.onboarding.topbar.listing'),
        link: `${guideRoot}/${nextStep}`,
      };
    case 'invitation':
      return {
        title: t('web.admin.onboarding.topbar.invitation'),
        link: `${guideRoot}/${nextStep}`,
      };
    default:
      return null;
  }
};

class OnboardingTopBar extends Component {

  nextElement() {
    const nextStep = next(this.props.next_step, Routes.admin_getting_started_guide_path());
    if (nextStep) {
      return (
        div({ className: css.nextContainer }, [
          div({ className: css.nextLabel }, t('web.admin.onboarding.topbar.next_step')),
          a({ href: nextStep.link, className: css.nextButton }, [
            span(nextStep.title),
          ]),
        ])
      );
    }
    return null;
  }

  render() {
    const currentProgress = this.props.progress;
    return div({ className: css.topbarContainer }, [
      div({ className: css.topbar }, [
        a({ className: css.progressLabel, href: Routes.admin_getting_started_guide_path() }, [
          t('web.admin.onboarding.topbar.progress_label'),
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
  progress: PropTypes.number.isRequired,
  next_step: PropTypes.string.isRequired,
};

export default OnboardingTopBar;
