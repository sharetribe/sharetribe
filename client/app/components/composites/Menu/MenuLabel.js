import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './Menu.css';
import hamburgerIcon from './images/hamburgerIcon.svg';

class MenuLabel extends Component {

  constructor(props, context) {
    super(props, context);

    this.toggleActive = this.toggleActive.bind(this);
    this.handleClick = this.handleClick.bind(this);
    this.handleKeyUp = this.handleKeyUp.bind(this);
    this.handleKeyDown = this.handleKeyDown.bind(this);
  }

  toggleActive() {
    this.props.onToggleActive();
  }

  handleKeyUp(e) {
    if (e.key === ' ') {
      this.toggleActive();
    }
  }

  handleKeyDown(e) {
    if (e.key === 'Enter') {
      this.toggleActive();
    }
  }

  handleClick() {
    this.toggleActive();
  }

  render() {
    return (
      div({
        className: `menu__label ${css.menuLabel}`,
        onClick: this.handleClick,
        onKeyUp: this.handleKeyUp,
        onKeyDown: this.handleKeyDown,
        onBlur: this.handleBlur,
        tabIndex: '-1',
      }, [
        span({
          className: css.menuLabelIcon,
          dangerouslySetInnerHTML: {
            __html: hamburgerIcon,
          },
        }),
        this.props.name,
      ])
    );
  }
}

const { bool, func, string } = PropTypes;

MenuLabel.propTypes = {
  onToggleActive: func.isRequired,
  isOpen: bool,
  hasFocus: bool.isRequired,
  name: string.isRequired,
};

export default MenuLabel;
