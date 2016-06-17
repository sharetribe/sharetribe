import { Component, PropTypes } from 'react';
import r, { div, img } from 'r-dom';
import _ from 'lodash';
import classNames from 'classnames';
import { className } from '../../../utils/PropTypes';
import ArrowDropdown from './ArrowDropdown';

import css from './Avatar.css';

class Avatar extends Component {
  constructor(props, context) {
    super(props, context);

    this.handleHover = this.handleHover.bind(this);

    this.state = {
      menuOpen: false,
    };

    this.menuCloseDelay = 300;
  }

  handleHover(event) {
    if (event && event.type === 'mouseover') {
      if (this.debouncedClose) {
        this.debouncedClose.cancel();
        this.debouncedClose = null;
      }
      this.setState({ menuOpen: true }); // eslint-disable-line react/no-set-state
    } else if (event && event.type === 'mouseout') {
      if (!this.debouncedClose) {
        this.debouncedClose = _.debounce(() => {
          this.setState({ menuOpen: false }); // eslint-disable-line react/no-set-state
        }, this.menuCloseDelay);
        this.debouncedClose();
      }
    }
  }

  render() {
    return div({
      onMouseOver: this.handleHover,
      onMouseOut: this.handleHover,
      className: classNames(this.props.className, css.avatar),
    }, [
      img({
        onClick: this.props.onClick,
        src: this.props.image,
        className: css.avatarImage,
        style: { height: this.props.imageHeight ? this.props.imageHeight : '100%' },
      }),
      this.state.menuOpen ?
        r(ArrowDropdown, {
          customColor: this.props.customColor,
          actions: this.props.actions,
          onMouseOver: this.handleHover,
          onMouseOut: this.handleHover,
        }) : null,
    ]);
  }
}

Avatar.propTypes = {
  image: PropTypes.string.isRequired,
  onClick: PropTypes.func.isRequired,
  imageHeight: PropTypes.number,
  ...ArrowDropdown.propTypes,
  className,
};

export default Avatar;
