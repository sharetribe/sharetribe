import { PropTypes } from 'react';
import r, { div, h2, p, img, a } from 'r-dom';
import css from './styles.scss';
import { t } from '../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';

const GuideInvitationPage = (props) => {
  const { changePage, initialPath, pageData, infoIcon } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, initialPath }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.invitation.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.invitation.description.content', {
      preview_link: a({
        href: '/?big_cover_photo=true',
        alt: t('web.admin.onboarding.guide.invitation.description.preview_link_alt'),
        target: '_blank',
      }, t('web.admin.onboarding.guide.invitation.description.preview_link')) })),

    pageData.info_image ?
      div({ className: css.sloganImageContainer }, [
        img({
          className: css.sloganImage,
          src: pageData.info_image,
          alt: t('web.admin.onboarding.guide.invitation.info_image_alt'),
        }),
      ]) :
      null,

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({ className: css.infoTextContent }, t('web.admin.onboarding.guide.invitation.advice')),
    ]),

    a({ className: css.nextButton, href: pageData.cta }, t('web.admin.onboarding.guide.invitation.invite_users')),
  ]);
};

GuideInvitationPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  infoIcon: PropTypes.string.isRequired,
  pageData: PropTypes.shape({
    cta: PropTypes.string.isRequired,
    info_image: PropTypes.string,
  }).isRequired,
};

export default GuideInvitationPage;
