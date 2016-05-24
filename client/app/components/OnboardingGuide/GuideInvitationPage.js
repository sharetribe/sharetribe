import { PropTypes } from 'react';
import r, { div, h2, p, img, a } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../utils/i18n';
import { Routes } from '../../utils/routes';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step7_screenshot_share@2x.png';

const GuideInvitationPage = (props) => {
  const { changePage, infoIcon } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.invitation.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.invitation.description.content', {
      preview_link: a({
        href: '/?big_cover_photo=true',
        alt: t('web.admin.onboarding.guide.invitation.description.preview_link_alt'),
        rel: 'noreferrer',
        target: '_blank',
      }, t('web.admin.onboarding.guide.invitation.description.preview_link')) })),

    div({ className: css.sloganImageContainer }, [
      img({
        className: css.sloganImage,
        src: infoImage,
        alt: t('web.admin.onboarding.guide.invitation.info_image_alt'),
      }),
    ]),

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({ className: css.infoTextContent }, t('web.admin.onboarding.guide.invitation.advice')),
    ]),

    a({ className: css.nextButton, href: Routes.new_invitation_path() }, t('web.admin.onboarding.guide.invitation.invite_users')),
  ]);
};

GuideInvitationPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  infoIcon: PropTypes.string.isRequired,
};

export default GuideInvitationPage;
