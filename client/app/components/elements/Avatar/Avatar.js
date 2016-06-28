import { Component, PropTypes } from 'react';
import { img } from 'r-dom';
import classNames from 'classnames';
import { className } from '../../../utils/PropTypes';

import css from './Avatar.css';

class Avatar extends Component {
  render() {
    return img({
      onClick: this.props.onClick,
      src: this.props.image,
      className: classNames(this.props.className, css.avatar),
      style: { height: this.props.imageHeight ? this.props.imageHeight : '100%' },
    });
  }
}

Avatar.propTypes = {
  image: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired,
  imageHeight: PropTypes.string,
  className,
};

export default Avatar;
