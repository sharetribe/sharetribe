import { PropTypes } from 'react';
import { a, div, img } from 'r-dom';
import classNames from 'classnames';
import * as propTypeUtils from '../../../utils/PropTypes';

import css from './Avatar.css';

export default function Avatar({ image, imageHeight, className, url, givenName, familyName, color }) {
  const displayName = [givenName, familyName].join(' ');
  const initials = [givenName, familyName].filter((n) => typeof n === 'string')
    .map((n) => n.substring(0, 1))
    .join('');
  const height = imageHeight ? imageHeight : '100%';
  const imageEl = img({
    src: image,
    className: classNames('Avatar', className, css.avatar),
    style: { height },
    title: displayName,
    alt: displayName,
  });
  const textEl = div({
    className: classNames('Avatar', className, css.textAvatar),
    style: { height, width: height, backgroundColor: color },
    title: displayName,
  }, initials);

  const displayEl = image ? imageEl : textEl;

  return url ? a({ href: url, className: css.link }, [displayEl]) : displayEl;
}

const { string } = PropTypes;

Avatar.propTypes = {
  url: string,
  image: string,
  imageHeight: string,
  className: propTypeUtils.className,
  givenName: string,
  familyName: string,
  color: string,
};
