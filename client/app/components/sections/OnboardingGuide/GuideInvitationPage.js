import { PropTypes } from 'react';
import r, { div, h2, p, img, a } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step7_screenshot_share@2x.png';

const GuideInvitationPage = (props) => {
  const { changePage, infoIcon, routes } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, routes }),
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

    a({ className: css.nextButton, href: routes.new_invitation_path() }, t('web.admin.onboarding.guide.invitation.invite_users')),
  ]);
};

const { func, string, shape } = PropTypes;

GuideInvitationPage.propTypes = {
  changePage: func.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    new_invitation_path: func.isRequired,
  }).isRequired,
};

export default GuideInvitationPage;
