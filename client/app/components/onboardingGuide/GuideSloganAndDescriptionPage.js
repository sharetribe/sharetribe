import { PropTypes } from 'react';
import r, { div, h2, p, img, a, i } from 'r-dom';
import css from './styles.scss';
import { t } from '../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';

const GuideSloganAndDescriptionPage = (props) => {
  const { changePage, initialPath, infoIcon, pageData } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, initialPath }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.slogan_and_description.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.slogan_and_description.description')),

    pageData.info_image ?
      div({ className: css.sloganImageContainer }, [
        img({
          className: css.sloganImage,
          src: props.pageData.info_image,
          alt: t('web.admin.onboarding.guide.slogan_and_description.info_image_alt'),
        }),
      ]) :
      null,

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

    a({ className: css.nextButton, href: pageData.cta }, t('web.admin.onboarding.guide.slogan_and_description.add_your_own')),
  ]);
};

GuideSloganAndDescriptionPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  infoIcon: PropTypes.string.isRequired,
  pageData: PropTypes.shape({
    cta: PropTypes.string.isRequired,
    info_image: PropTypes.string,
  }).isRequired,
};

export default GuideSloganAndDescriptionPage;
