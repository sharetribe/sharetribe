import { Component, PropTypes } from 'react';
import r, { a } from 'r-dom';
import classNames from 'classnames';
import { className } from '../../../utils/PropTypes';

import css from './Logo.css';

const logoContent = function logoContent(image, text) {
  let content = null;
  if (image) {
    content = r.img({ src: image, alt: text, className: css.logoImage });
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
    }, logoContent(this.props.image, this.props.text));
  }
}

Logo.propTypes = {
  href: PropTypes.string.isRequired,
  image: PropTypes.string,
  text: PropTypes.string.isRequired,
  className,
};

export default Logo;
