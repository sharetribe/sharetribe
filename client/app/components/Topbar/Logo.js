import { Component, PropTypes } from 'react';
import r, { div, a } from 'r-dom';
import classNames from 'classnames';

import css from './Logo.css';

const logoContent = function logoContent(image, text) {
  let content = null;
  if (image) {
    content = r.img({ src: image, className: css.logoImage });
  } else if (text) {
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
  text: PropTypes.string,
  className: PropTypes.oneOfType([
    PropTypes.string,
    PropTypes.objectOf(PropTypes.bool),
  ]),
};

export default Logo;
