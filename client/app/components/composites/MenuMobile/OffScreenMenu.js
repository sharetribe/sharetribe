import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import * as variables from '../../../assets/styles/variables';
import css from './MenuMobile.css';
import MenuSection from './MenuSection';
import Avatar from '../../elements/Avatar/Avatar';
import AddNewListingButton from '../../elements/AddNewListingButton/AddNewListingButton';
import LoginLinks from '../../composites/LoginLinks/LoginLinks';

class OffScreenMenu extends Component {

  render() {
    const isOpenClass = this.props.isOpen ? css.offScreenMenuOpen : '';
    const headerItemHeight = variables['--MobileMenu_offscreenHeaderItemHeight'];

    const avatarExtras = { imageHeight: headerItemHeight };
    const buttonExtras = { className: css.offScreenHeaderNewListingButton };
    const header = this.props.avatar ? [
      this.props.avatar ? r(Avatar, { ...this.props.avatar, ...avatarExtras }) : null,
      this.props.newListingButton ? r(AddNewListingButton, { ...this.props.newListingButton, ...buttonExtras }) : null,
    ] : [
      r(LoginLinks, this.props.loginLinks),
    ];

    return div({
      className: `OffScreenMenu ${css.offScreenMenu} ${isOpenClass}`,
    }, [
      div({
        className: `OffScreenMenu_header ${css.offScreenHeader}`,
      }, header),
      div({
        className: `OffScreenMenu_main ${css.offScreenMain}`,
      }, [
        r(MenuSection, {
          name: this.props.menuLinksTitle,
          color: this.props.color,
          links: this.props.menuLinks,
        }),
        r(MenuSection, {
          name: this.props.userLinksTitle,
          color: this.props.color,
          links: this.props.userLinks,
        }),
      ]),
      div({
        className: `OffScreenMenu_footer ${css.offScreenFooter}`,
      }),
    ]);
  }
}

OffScreenMenu.propTypes = {
  color: PropTypes.string.isRequired,
  isOpen: PropTypes.bool.isRequired,
  menuLinksTitle: PropTypes.string.isRequired,
  menuLinks: PropTypes.arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
    })
  ).isRequired,
  userLinksTitle: PropTypes.string.isRequired,
  userLinks: PropTypes.arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
    })
  ),
  avatar: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  newListingButton: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  loginLinks: PropTypes.object, // eslint-disable-line react/forbid-prop-types
};

export default OffScreenMenu;
