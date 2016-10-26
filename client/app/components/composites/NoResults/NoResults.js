import { PropTypes } from 'react';
import { div, p } from 'r-dom';
import classNames from 'classnames';

import { t } from '../../../utils/i18n';

import css from './NoResults.css';
import sadIcon from './images/sadIcon.svg';

export default function NoResults({ className }) {

  return div({
    className: classNames(className, css.container),
  }, [
    div({
      className: css.sadIcon,
      dangerouslySetInnerHTML: { __html: sadIcon },
    }),
    div({
      className: css.message,
    }, [
      p({}, t('web.no_listings.sorry')),
      p({}, t('web.no_listings.try_other_search_terms')),
    ]),
  ]);
}

NoResults.propTypes = {
  className: PropTypes.string,
};
