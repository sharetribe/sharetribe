import { PropTypes } from 'react';
import r, { div, h2, p, img, a } from 'r-dom';
import css from './styles.scss';

import GuideBackToTodoLink from './GuideBackToTodoLink';

const GuideSloganAndDescriptionPage = (props) => {
  const { changePage, initialPath, t, infoIcon, pageData } = props;

  return div({ className: 'container' }, [
    r(GuideBackToTodoLink, { changePage, initialPath, t }),
    h2({ className: css.title }, t('title')),
    p({ className: css.description }, t('description')),

    pageData.info_image ?
      div({ className: css.sloganImageContainer }, [
        img({
          className: css.sloganImage,
          src: props.pageData.info_image,
          alt: t('info_image_alt'),
        }),
      ]) :
      null,

    div({ className: css.infoTextContainer }, [
      div({ className: css.infoTextIcon, dangerouslySetInnerHTML: { __html: infoIcon } }),
      div({ className: css.infoTextContent, dangerouslySetInnerHTML: { __html: t('advice') } }),
    ]),

    a({ className: css.nextButton, href: pageData.cta }, t('add_your_own')),
  ]);
};

GuideSloganAndDescriptionPage.propTypes = {
  changePage: PropTypes.func.isRequired,
  initialPath: PropTypes.string.isRequired,
  t: PropTypes.func.isRequired,
  infoIcon: PropTypes.string.isRequired,
  pageData: PropTypes.shape({
    cta: PropTypes.string.isRequired,
    info_image: PropTypes.string,
  }).isRequired,
};

export default GuideSloganAndDescriptionPage;
