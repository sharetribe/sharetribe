import { PropTypes } from 'react';
import { div, span } from 'r-dom';
import classNames from 'classnames';

import * as propTypeUtils from '../../../utils/PropTypes';
import css from './NotificationBadge.css';

export default function NotificationBadge({ className, countClassName, children }) {
  return div({
    className: classNames(css.notificationBadge, className),
  },
  span({ className: classNames(css.notificationBadgeCount, countClassName) }, children));
}

const { arrayOf, node, oneOfType } = PropTypes;

NotificationBadge.propTypes = {
  className: propTypeUtils.className,
  countClassName: propTypeUtils.className,
  children: oneOfType([
    arrayOf(node),
    node,
  ]),
};
