import { PropTypes } from 'react';
import r, { div, h2, p, img, a, i } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../utils/i18n';
import { Routes } from '../../utils/routes';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step2_sloganDescription.jpg';

const GuideSloganAndDescriptionPage = (props) => {
  const { changePage, infoIcon, pageData } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage }),
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

    a({ className: css.nextButton, href: Routes.admin_details_edit_path() }, t('web.admin.onboarding.guide.slogan_and_description.add_your_own')),
  ]);
};

GuideSloganAndDescriptionPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  infoIcon: PropTypes.string.isRequired,
};

export default GuideSloganAndDescriptionPage;
