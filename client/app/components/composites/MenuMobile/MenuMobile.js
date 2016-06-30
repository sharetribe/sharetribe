import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import classNames from 'classnames';

import { className } from '../../../utils/PropTypes';

import css from './MenuMobile.css';
import OffScreenMenu from './OffScreenMenu';
import MenuLabelMobile from './MenuLabelMobile';

class MenuMobile extends Component {

  constructor(props, context) {
    super(props, context);

    this.handleClick = this.handleClick.bind(this);
    this.closeMenu = this.closeMenu.bind(this);
    this.state = {
      isOpen: false,
    };
  }

  handleClick() {
    this.setState({ isOpen: !this.state.isOpen });// eslint-disable-line react/no-set-state
  }

  closeMenu() {
    this.setState({ isOpen: false });// eslint-disable-line react/no-set-state
  }

  render() {
    const overlayColor = this.props.color ? this.props.color : 'black';
    const openClass = this.state.isOpen ? css.canvasOpen : '';
    const extraClasses = this.props.extraClasses ? this.props.extraClasses : '';

    return div({
      className: classNames(this.props.className, 'MenuMobile', css.menuMobile, extraClasses, openClass),
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
        avatar: this.props.avatar,
        newListingButton: this.props.newListingButton,
        loginLinks: this.props.loginLinks,
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
  className,
  avatar: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  newListingButton: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  loginLinks: PropTypes.object, // eslint-disable-line react/forbid-prop-types
};

export default MenuMobile;
