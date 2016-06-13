import { Component, PropTypes } from 'react';
import r, { div, img } from 'r-dom';
import classNames from 'classnames';
import { className } from '../../../utils/PropTypes';
import ArrowDropdown from './ArrowDropdown';

import css from './Avatar.css';

class Avatar extends Component {
  render() {
    return div({
      className: classNames(this.props.className, css.avatar),
    }, [
      img({
        onClick: this.props.onClick,
        src: this.props.image,
        className: css.avatarImage,
      }),
      r(ArrowDropdown, { customColor: this.props.customColor, actions: this.props.actions }),
    ]);
  }
}

Avatar.propTypes = {
  image: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired,
  ...ArrowDropdown.propTypes,
  className,
};

export default Avatar;
