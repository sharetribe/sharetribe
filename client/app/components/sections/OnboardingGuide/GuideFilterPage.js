import { PropTypes } from 'react';
import r, { div, h2, p, img, a, i } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step4_fieldsFilters.jpg';

const GuideFilterPage = (props) => {
  const { changePage, infoIcon, routes } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, routes }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.filter.title')),
    p({ className: css.description }, [
      t('web.admin.onboarding.guide.filter.description.content',
          { display_on_homepage: i(t('web.admin.onboarding.guide.filter.description.display_on_homepage')) }),
    ]),

    div({ className: css.sloganImageContainerBig }, [
      img({
        className: css.sloganImage,
        src: infoImage,
        alt: t('web.admin.onboarding.guide.filter.info_image_alt'),
      }),
    ]),

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({
        className: css.infoTextContent }, [
          t('web.admin.onboarding.guide.filter.advice.content',
            { not_too_many_link: a({
              target: '_blank',
              rel: 'noreferrer',
              href: 'https://www.sharetribe.com/academy/how-to-help-your-customers-find-the-right-product-or-service/?utm_source=marketplaceadminpanel&utm_medium=referral&utm_campaign=onboardingguide',
            }, t('web.admin.onboarding.guide.filter.advice.not_too_many_link')) }),
        ]),
    ]),

    a({ className: css.nextButton, href: routes.admin_custom_fields_path() }, t('web.admin.onboarding.guide.filter.add_fields_and_filters')),
  ]);
};

const { func, string, shape } = PropTypes;

GuideFilterPage.propTypes = {
  changePage: func.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    admin_custom_fields_path: func.isRequired,
  }).isRequired,
};

export default GuideFilterPage;
