import PropTypes from 'prop-types';
import r, { div, h2, p, img, a, br, span } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step3_coverPhoto.jpg';

const COVER_PHOTO_WIDTH = 1920;
const COVER_PHOTO_HEIGHT = 450;

const GuideCoverPhotoPage = (props) => {
  const { changePage, infoIcon, routes } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, routes }),
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
            {
              link: a(
                {
                  href: 'https://docs.google.com/document/d/1AdGRFAxQkc_g9UP-IUtwAwo5eOAvGGOw2md-LjybR60/#heading=h.d9vqnj9u47uj',
                  target: '_blank',
                  rel: 'noreferrer',
                  alt: t('web.admin.onboarding.guide.cover_photo.advice.alt'),
                },
                t('web.admin.onboarding.guide.cover_photo.advice.link')
              ),
              link_images: a(
                {
                  href: 'https://docs.google.com/document/d/1AdGRFAxQkc_g9UP-IUtwAwo5eOAvGGOw2md-LjybR60/#heading=h.fw13fn2qvjfb',
                  target: '_blank',
                  rel: 'noreferrer',
                  alt: t('web.admin.onboarding.guide.cover_photo.advice.alt_images'),
                },
                t('web.admin.onboarding.guide.cover_photo.advice.link_images')
              ),
            }
          )
        ),
        br(),
        t('web.admin.onboarding.guide.cover_photo.advice.content2', { width: COVER_PHOTO_WIDTH, height: COVER_PHOTO_HEIGHT }),
      ]),
    ]),

    a({ className: css.nextButton, href: routes.admin_look_and_feel_edit_path() }, t('web.admin.onboarding.guide.cover_photo.add_your_own')),
  ]);
};

const { func, string, shape } = PropTypes;

GuideCoverPhotoPage.propTypes = {
  changePage: func.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    admin_look_and_feel_edit_path: func.isRequired,
  }).isRequired,
};

export default GuideCoverPhotoPage;
