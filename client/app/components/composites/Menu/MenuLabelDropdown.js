import { Component, PropTypes } from 'react';
import { div, span } from 'r-dom';
import css from './Menu.css';
import openIcon from './images/dropdownTriangleOpen.svg';
import closedIcon from './images/dropdownTriangleClosed.svg';

class MenuLabelDropdown extends Component {

  render() {
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';
    return (
      div({
        className: `menu__label ${css.menuLabel} ${extraClasses}`,
      }, [
        this.props.name,
        span({
          className: css.menuLabelDropdownIconOpen,
          dangerouslySetInnerHTML: { __html: openIcon },
        }),
        span({
          className: css.menuLabelDropdownIconClosed,
          dangerouslySetInnerHTML: { __html: closedIcon },
        }),
      ])
    );
  }
}

MenuLabelDropdown.propTypes = {
  name: PropTypes.string.isRequired,
  extraClasses: PropTypes.string,
};

export default MenuLabelDropdown;
