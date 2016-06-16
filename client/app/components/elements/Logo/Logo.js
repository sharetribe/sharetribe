import { Component, PropTypes } from 'react';
import r, { a } from 'r-dom';
import classNames from 'classnames';
import { className } from '../../../utils/PropTypes';

import css from './Logo.css';

const logoContent = function logoContent(image, imageHighRes, text) {
  let content = null;
  if (image) {
    content = r.img({
      src: image,
      srcSet: `${imageHighRes} 2x`,
      alt: text,
      className: css.logoImage,
    });
  } else {
    content = r.span({ className: css.logoText }, text);
  }
  return content;
};

class Logo extends Component {
  render() {
    return a({
      className: classNames(this.props.className, css.logo),
      href: this.props.href,
    }, logoContent(this.props.image, this.props.image_highres, this.props.text));
  }
}

Logo.propTypes = {
  href: PropTypes.string.isRequired,
  image: PropTypes.string,
  image_highres: PropTypes.string,
  text: PropTypes.string.isRequired,
  className,
};

export default Logo;
