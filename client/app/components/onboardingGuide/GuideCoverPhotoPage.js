import { PropTypes } from 'react';
import r, { div, h2, p, img, a, br } from 'r-dom';
import css from './styles.scss';
import { t } from '../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';

const GuideCoverPhotoPage = (props) => {
  const { changePage, initialPath, pageData, infoIcon } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, initialPath }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.cover_photo.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.cover_photo.description')),

    pageData.info_image ?
      div({ className: css.sloganImageContainer }, [
        img({
          className: css.sloganImage,
          src: pageData.info_image,
          alt: t('web.admin.onboarding.guide.cover_photo.info_image_alt'),
        }),
      ]) :
      null,

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({
        className: css.infoTextContent,
      }, [
        t('web.admin.onboarding.guide.cover_photo.advice.content1',
          { link: a({
            href: 'http://support.sharetribe.com/knowledgebase/articles/744438',
            target: '_blank',
            rel: 'noreferrer',
            alt: t('web.admin.onboarding.guide.cover_photo.advice.alt'),
          }, t('web.admin.onboarding.guide.cover_photo.advice.link')) }),
        br(),
        t('web.admin.onboarding.guide.cover_photo.advice.content2', { width: 1920, height: 450 }),
      ]),
    ]),

    a({ className: css.nextButton, href: pageData.cta }, t('web.admin.onboarding.guide.cover_photo.add_your_own')),
  ]);
};

GuideCoverPhotoPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  infoIcon: PropTypes.string.isRequired,
  pageData: PropTypes.shape({
    cta: PropTypes.string.isRequired,
    info_image: PropTypes.string,
  }).isRequired,
};

export default GuideCoverPhotoPage;
