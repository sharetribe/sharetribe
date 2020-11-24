import { Component, PropTypes } from 'react';
import { div, span, a } from 'r-dom';
import { t } from '../../../utils/i18n';

import css from './OnboardingTopBar.css';

const next = function next(nextStep, routes) {
  switch (nextStep) {
    case 'slogan_and_description':
      return {
        title: t('web.admin.onboarding.topbar.slogan_and_description'),
        link: routes.admin_getting_started_guide_slogan_and_description_path(),
      };
    case 'cover_photo':
      return {
        title: t('web.admin.onboarding.topbar.cover_photo'),
        link: routes.admin_getting_started_guide_cover_photo_path(),
      };
    case 'filter':
      return {
        title: t('web.admin.onboarding.topbar.filter'),
        link: routes.admin_getting_started_guide_filter_path(),
      };
    case 'payment':
      return {
        title: t('web.admin.onboarding.topbar.paypal'),
        link: routes.admin_getting_started_guide_payment_path(),
      };
    case 'listing':
      return {
        title: t('web.admin.onboarding.topbar.listing'),
        link: routes.admin_getting_started_guide_listing_path(),
      };
    case 'invitation':
      return {
        title: t('web.admin.onboarding.topbar.invitation'),
        link: routes.admin_getting_started_guide_invitation_path(),
      };
    default:
      return null;
  }
};

class OnboardingTopBar extends Component {

  nextElement() {
    const nextStep = next(this.props.next_step, this.props.routes);
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
        a({ className: css.progressLabel, href: this.props.routes.admin_getting_started_guide_path() }, [
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

const { number, string, shape, func } = PropTypes;

OnboardingTopBar.propTypes = {
  progress: number.isRequired,
  next_step: string.isRequired,
  routes: shape({
    admin_getting_started_guide_path: func.isRequired,
    admin_getting_started_guide_slogan_and_description_path: func.isRequired,
    admin_getting_started_guide_cover_photo_path: func.isRequired,
    admin_getting_started_guide_filter_path: func.isRequired,
    admin_getting_started_guide_payment_path: func.isRequired,
    admin_getting_started_guide_listing_path: func.isRequired,
    admin_getting_started_guide_invitation_path: func.isRequired,
  }).isRequired,
};

export default OnboardingTopBar;
