import { PropTypes } from 'react';
import { a, img } from 'r-dom';
import classNames from 'classnames';
import * as propTypeUtils from '../../../utils/PropTypes';

import css from './Avatar.css';

export default function Avatar({ image, imageHeight, className, url }) {
  const height = imageHeight ? imageHeight : '100%';
  const imageEl = img({
    src: image,
    className: classNames(className, css.avatar),
    style: { height },
  });

  return url ? a({ href: url, className: css.link }, [imageEl]) : imageEl;
}

const { string } = PropTypes;

Avatar.propTypes = {
  url: string,
  image: string.isRequired,
  imageHeight: string,
  className: propTypeUtils.className,
};
