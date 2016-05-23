import { PropTypes } from 'react';
import r, { div, h2, p, img, a, br, span } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step3_coverPhoto.jpg';

const COVER_PHOTO_WIDTH = 1920;
const COVER_PHOTO_HEIGHT = 450;

const GuideCoverPhotoPage = (props) => {
  const { changePage, pageData, infoIcon } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.cover_photo.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.cover_photo.description')),

    div({ className: css.sloganImageContainer }, [
      img({
        className: css.sloganImage,
        src: infoImage,
        alt: t('web.admin.onboarding.guide.cover_photo.info_image_alt'),
      }),
    ]),

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({
        className: css.infoTextContent,
      }, [
        span(
          t('web.admin.onboarding.guide.cover_photo.advice.content1',
            { link: a({
              href: 'http://support.sharetribe.com/knowledgebase/articles/744438',
              target: '_blank',
              rel: 'noreferrer',
              alt: t('web.admin.onboarding.guide.cover_photo.advice.alt'),
            }, t('web.admin.onboarding.guide.cover_photo.advice.link')) })),
        br(),
        t('web.admin.onboarding.guide.cover_photo.advice.content2', { width: COVER_PHOTO_WIDTH, height: COVER_PHOTO_HEIGHT }),
      ]),
    ]),

    a({ className: css.nextButton, href: pageData.cta }, t('web.admin.onboarding.guide.cover_photo.add_your_own')),
  ]);
};

GuideCoverPhotoPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  infoIcon: PropTypes.string.isRequired,
  pageData: PropTypes.shape({
    cta: PropTypes.string.isRequired,
  }).isRequired,
};

export default GuideCoverPhotoPage;
