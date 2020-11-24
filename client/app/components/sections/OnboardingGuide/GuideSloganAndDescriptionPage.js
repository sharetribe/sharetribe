import { PropTypes } from 'react';
import r, { div, h2, p, img, a, i } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step2_sloganDescription.jpg';

const GuideSloganAndDescriptionPage = (props) => {
  const { changePage, infoIcon, routes } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, routes }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.slogan_and_description.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.slogan_and_description.description')),

    div({ className: css.sloganImageContainer }, [
      img({
        className: css.sloganImage,
        src: infoImage,
        alt: t('web.admin.onboarding.guide.slogan_and_description.info_image_alt'),
      }),
    ]),

    div({ className: css.infoTextContainer }, [
      div({ className: css.infoTextIcon, dangerouslySetInnerHTML: { __html: infoIcon } }),
      div({ className: css.infoTextContent },
          t('web.admin.onboarding.guide.slogan_and_description.advice.content',
            {
              food_from_locals_slogan: i(t('web.admin.onboarding.guide.slogan_and_description.advice.food_from_locals_slogan')),
              food_from_locals_description: i(t('web.admin.onboarding.guide.slogan_and_description.advice.food_from_locals_description')),
              guitar_lessons_slogan: i(t('web.admin.onboarding.guide.slogan_and_description.advice.guitar_lessons_slogan')),
              guitar_lessons_description: i(t('web.admin.onboarding.guide.slogan_and_description.advice.guitar_lessons_description')),
            })),
    ]),

    a({ className: css.nextButton, href: routes.admin_details_edit_path() }, t('web.admin.onboarding.guide.slogan_and_description.add_your_own')),
  ]);
};

const { func, string, shape } = PropTypes;

GuideSloganAndDescriptionPage.propTypes = {
  changePage: func.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    admin_details_edit_path: func.isRequired,
  }).isRequired,
};

export default GuideSloganAndDescriptionPage;
