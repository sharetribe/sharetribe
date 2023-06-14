import { PropTypes } from 'react';
import r, { div, h2, p, img, a, i } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';
import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step6_addListing.jpg';

const GuideListingPage = (props) => {
  const { changePage, infoIcon, routes } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, routes }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.listing.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.listing.description')),

    div({ className: css.sloganImageContainerBig }, [
      img({
        className: css.sloganImage,
        src: infoImage,
        alt: t('web.admin.onboarding.guide.listing.info_image_alt'),
      }),
    ]),

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({ className: css.infoTextContent },
          t('web.admin.onboarding.guide.listing.advice.content', { close_listing: i(t('web.admin.onboarding.guide.listing.advice.close_listing')) })),
    ]),

    a({ className: css.nextButton, href: routes.new_listing_path() }, t('web.admin.onboarding.guide.listing.post_your_first_listing')),
  ]);
};

const { func, string, shape } = PropTypes;

GuideListingPage.propTypes = {
  changePage: func.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    new_listing_path: func.isRequired,
  }),
};

export default GuideListingPage;
