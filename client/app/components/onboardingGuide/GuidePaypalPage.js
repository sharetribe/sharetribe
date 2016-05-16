import { PropTypes } from 'react';
import r, { div, h2, p, img, a, span } from 'r-dom';
import css from './styles.scss';
import { t } from '../../utils/i18n';

import GuideBackToTodoLink from './GuideBackToTodoLink';

const GuidePaypalPage = (props) => {
  const { changePage, initialPath, pageData, infoIcon } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, initialPath }),
    h2({ className: css.title }, t('web.admin.onboarding.guide.paypal.title')),
    p({ className: css.description }, t('web.admin.onboarding.guide.paypal.description_p1')),
    p({ className: css.description }, t('web.admin.onboarding.guide.paypal.description_p2')),

    pageData.info_image ?
      div({ className: css.sloganImageContainer }, [
        img({
          className: css.sloganImage,
          src: pageData.info_image,
          alt: t('web.admin.onboarding.guide.paypal.info_image_alt'),
        }),
      ]) :
      null,

    div({ className: css.infoTextContainer }, [
      div({
        className: css.infoTextIcon,
        dangerouslySetInnerHTML: { __html: infoIcon }, // eslint-disable-line react/no-danger
      }),
      div({ className: css.infoTextContent }, t('web.admin.onboarding.guide.paypal.advice.content', {
        disable_payments_link: a(
          { href: 'http://support.sharetribe.com/knowledgebase/articles/470085',
            target: '_blank',
            alt: t('web.admin.onboarding.guide.paypal.advice.disable_payments_alt'),
          },
          t('web.admin.onboarding.guide.paypal.advice.disable_payments_link')),
      })),
    ]),

    div(null, [
      a({ className: css.nextButton, href: pageData.cta }, t('web.admin.onboarding.guide.paypal.setup_payments')),
      span({ className: css.buttonSeparator }, t('web.admin.onboarding.guide.paypal.cta_separator')),
      a({ className: css.nextButtonGhost, href: pageData.alternative_cta }, t('web.admin.onboarding.guide.paypal.disable_payments')),
    ]),
  ]);
};

GuidePaypalPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  infoIcon: PropTypes.string.isRequired,
  pageData: PropTypes.shape({
    cta: PropTypes.string.isRequired,
    alternative_cta: PropTypes.string.isRequired,
    info_image: PropTypes.string,
  }).isRequired,
};

export default GuidePaypalPage;
