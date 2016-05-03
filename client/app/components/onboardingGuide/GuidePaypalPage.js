import { PropTypes } from 'react';
import r, { div, h2, p, img, a, span} from 'r-dom';
import css from './styles.scss';

import GuideBackToTodoLink from './GuideBackToTodoLink';

const GuidePaypalPage = (props) => {
  const { changePage, initialPath, t, pageData, infoIcon } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, initialPath, t }),
    h2({ className: css.title }, t('title')),
    p({ className: css.description }, t('description_p1')),
    p({ className: css.description }, t('description_p2')),

    pageData.info_image ?
      div({ className: css.sloganImageContainer }, [
        img({
          className: css.sloganImage,
          src: pageData.info_image,
          alt: t('info_image_alt'),
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
        dangerouslySetInnerHTML: { __html: t('advice') }, // eslint-disable-line react/no-danger
      }),
    ]),

    div(null, [
      a({ className: css.nextButton, href: pageData.cta }, t('setup_payments')),
      span({ className: css.buttonSeparator}, t('cta_separator')),
      a({ className: css.nextButtonGhost, href: pageData.alternative_cta }, t('disable_payments')),
    ]),
  ]);
};

GuidePaypalPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  infoIcon: PropTypes.string.isRequired,
  pageData: PropTypes.shape({
    cta: PropTypes.string.isRequired,
    alternative_cta: PropTypes.string.isRequired,
    info_image: PropTypes.string,
  }).isRequired,
};

export default GuidePaypalPage;
