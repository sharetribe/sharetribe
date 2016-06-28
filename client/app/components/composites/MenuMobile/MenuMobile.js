import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import css from './MenuMobile.css';
import OffScreenMenu from './OffScreenMenu';
import MenuLabelMobile from './MenuLabelMobile';

class MenuMobile extends Component {

  constructor(props, context) {
    super(props, context);

    this.handleClick = this.handleClick.bind(this);
    this.handleBlur = this.handleBlur.bind(this);
    this.closeMenu = this.closeMenu.bind(this);
    this.state = {
      isOpen: false,
    };
  }

  handleClick() {
    this.setState({ isOpen: !this.state.isOpen });// eslint-disable-line react/no-set-state
  }

  handleBlur() {
    this.closeMenu();
  }

  closeMenu() {
    this.setState({ isOpen: false });// eslint-disable-line react/no-set-state
  }

  render() {
    const overlayColor = this.props.color ? this.props.color : 'black';
    const openClass = this.state.isOpen ? css.canvasOpen : '';
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';

    return div({
      className: `MenuMobile ${css.menuMobile} ${extraClasses} ${openClass}`,
      onBlur: this.handleBlur,
      tabIndex: 0,
    }, [
      div({
        style: { backgroundColor: overlayColor },
        onClick: this.closeMenu,
        className: `MenuMobile_overlay ${css.overlay}`,
      }),
      r(MenuLabelMobile, {
        name: this.props.name,
        handleClick: this.handleClick,
      }),
      r(OffScreenMenu, {
        toggleOpen: this.closeMenu,
        isOpen: this.state.isOpen,
        color: overlayColor,
        menuLinksTitle: this.props.menuLinksTitle,
        menuLinks: this.props.menuLinks,
        userLinksTitle: this.props.userLinksTitle,
        userLinks: this.props.userLinks,
      }),
    ]);
  }
}

MenuMobile.propTypes = {
  name: PropTypes.string.isRequired,
  extraClasses: PropTypes.string,
  identifier: PropTypes.string.isRequired,
  color: PropTypes.string,
  menuLinksTitle: PropTypes.string,
  menuLinks: PropTypes.arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
    })
  ).isRequired,
  userLinksTitle: PropTypes.string,
  userLinks: PropTypes.arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
    })
  ),
};

export default MenuMobile;
