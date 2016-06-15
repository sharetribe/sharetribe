import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './Menu.css';
import openIcon from './images/dropdownTriangleOpen.svg';
import closedIcon from './images/dropdownTriangleClosed.svg';

class MenuLabelDropdown extends Component {

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
        this.props.name,
        span({
          className: css.menuLabelDropdownIcon,
          dangerouslySetInnerHTML: {
            __html: this.props.isOpen ?
              openIcon :
              closedIcon,
          },
        }),
      ])
    );
  }
}

const { bool, func, string } = PropTypes;

MenuLabelDropdown.propTypes = {
  onToggleActive: func.isRequired,
  isOpen: bool.isRequired,
  hasFocus: bool.isRequired,
  name: string.isRequired,
};

export default MenuLabelDropdown;
