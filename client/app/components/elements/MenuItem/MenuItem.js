import { Component, PropTypes } from 'react';
import { div, a, span } from 'r-dom';

import css from './MenuItem.css';

class MenuItem extends Component {

  constructor(props, context) {
    super(props, context);
    this.activeColor = this.props.activeColor || '#a64c5d';

    this.handleHover = this.handleHover.bind(this);
  }

  handleHover() {
    this.props.hoverFocus(this.props.index);
  }


  render() {
    return div({ className: css.menuitem }, [
      this.props.active ?
        span({
          className: css.activeIndicator,
          style: { backgroundColor: this.activeColor },
        }) :
        null,
      a(
        {
          className: `menuitem ${css.menuitemLink}`,
          href: this.props.href,
          tabIndex: '-1',
          onMouseOver: this.handleHover,
        },
        this.props.content),
    ]);
  }
}

const { bool, func, number, string } = PropTypes;

MenuItem.propTypes = {
  active: bool.isRequired,
  activeColor: string.isRequired,
  content: string.isRequired,
  hoverFocus: func.isRequired,
  href: string.isRequired,
  index: number.isRequired,
  type: string.isRequired,
};

export default MenuItem;
