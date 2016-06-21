import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import _ from 'lodash';
import classNames from 'classnames';
import { className } from '../../../utils/PropTypes';
import ArrowDropdown from './ArrowDropdown';
import Avatar from '../../elements/Avatar/Avatar';

import css from './AvatarDropdown.css';

class AvatarDropdown extends Component {
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
      className: classNames(this.props.className, css.avatarDropdown),
    }, [
      r(Avatar, this.props.avatar),
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

AvatarDropdown.propTypes = {
  avatar: PropTypes.shape(Avatar.propTypes).isRequired,
  ...ArrowDropdown.propTypes,
  className,
};

export default AvatarDropdown;
