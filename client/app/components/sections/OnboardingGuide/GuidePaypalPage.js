import PropTypes from 'prop-types';
import r, { div, h2, p, img, a, span } from 'r-dom';
import css from './OnboardingGuide.css';
import { t } from '../../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';
import infoImage from './images/step5_screenshot_paypal@2x.png';

const GuidePaypalPage = (props) => {
  const { changePage, pageData, infoIcon, routes } = props; // eslint-disable-line no-unused-vars
  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, routes }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.payments.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.payments.description_p1', {
      not_sure_link: a(
        {
          href: '#',
          id: 'not_sure_link',
          target: '_blank',
          rel: 'noreferrer',
          alt: t('web.admin.onboarding.guide.payments.not_sure_link'),
        },
        t('web.admin.onboarding.guide.payments.not_sure_link')
      ),
    })),
    p({ className: css.description }, t('web.admin.onboarding.guide.payments.description_p2')),

    div({ className: css.sloganImageContainer }, [
      img({
        className: css.sloganImage,
        src: infoImage,
        alt: t('web.admin.onboarding.guide.payments.info_image_alt'),
      }),
    ]),

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({ className: css.infoTextContent }, t('web.admin.onboarding.guide.payments.advice.content_paypal_stripe', {
        disable_payments_link: a(
          { href: 'https://docs.google.com/document/d/1AdGRFAxQkc_g9UP-IUtwAwo5eOAvGGOw2md-LjybR60/#heading=h.bze42gize39y',
            target: '_blank',
            rel: 'noreferrer',
            alt: t('web.admin.onboarding.guide.payments.advice.disable_payments_alt'),
          },
          t('web.admin.onboarding.guide.payments.advice.disable_payments_link')),
        stripe_paypal_link: a(
          { href: 'https://docs.google.com/document/d/1AdGRFAxQkc_g9UP-IUtwAwo5eOAvGGOw2md-LjybR60/#heading=h.1t23qgqd07fe',
            target: '_blank',
            rel: 'noreferrer',
            alt: t('web.admin.onboarding.guide.payments.advice.stripe_paypal_link'),
          },
          t('web.admin.onboarding.guide.payments.advice.stripe_paypal_link')),
      })),
    ]),

    div(null, [
      a({ className: css.nextButton, href: routes.admin_payment_preferences_path() }, t('web.admin.onboarding.guide.payments.setup_payments')),
      span({ className: css.buttonSeparator }, t('web.admin.onboarding.guide.payments.cta_separator')),
      a({ className: css.nextButtonGhost, href: routes.admin_getting_started_guide_path() }, t('web.admin.onboarding.guide.next_step.skip_this_step_for_now')),
    ]),
    div({ className: css.disablePayments }, [
      span(null,
        t('web.admin.onboarding.guide.payments.i_dont_want', {
          link: a({ href: routes.admin_getting_started_guide_skip_payment_path() }, t('web.admin.onboarding.guide.payments.disable_it')),
        })),
    ]),
  ]);
};

const { func, string, shape } = PropTypes;

GuidePaypalPage.propTypes = {
  changePage: func.isRequired,
  infoIcon: string.isRequired,
  routes: shape({
    edit_admin_listing_shape_path: func.isRequired,
  }),
  pageData: shape({
    additional_info: shape({
      listing_shape_name: string,
    }).isRequired,
  }).isRequired,
};

export default GuidePaypalPage;
