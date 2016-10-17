import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import classNames from 'classnames';

import * as variables from '../../../assets/styles/variables';
import css from './MenuMobile.css';
import MenuSection from './MenuSection';
import LanguagesMobile from './LanguagesMobile';
import Avatar from '../../elements/Avatar/Avatar';
import AddNewListingButton from '../../elements/AddNewListingButton/AddNewListingButton';
import LoginLinks from '../../composites/LoginLinks/LoginLinks';

class OffScreenMenu extends Component {

  render() {
    const headerItemHeight = variables['--MobileMenu_offscreenHeaderItemHeight'];

    const avatarExtras = { imageHeight: headerItemHeight };
    const buttonExtras = { className: css.offScreenHeaderNewListingButton, customColor: this.props.color };
    const header = this.props.avatar ? [
      this.props.avatar ? div({ className: css.avatarSpacer }, r(Avatar, { ...this.props.avatar, ...avatarExtras })) : null,
      this.props.newListingButton ? r(AddNewListingButton, { ...this.props.newListingButton, ...buttonExtras }) : null,
    ] : [
      r(LoginLinks, this.props.loginLinks),
    ];
    const languagesMobile = this.props.languages ?
      r(LanguagesMobile, this.props.languages) : null;

    return div({
      className: classNames('OffScreenMenu', css.offScreenMenu),
    }, div({
      className: classNames('OffScreenMenu_scrollpane', css.scrollPane),
    }, [
      div({
        className: classNames('OffScreenMenu_header', css.offScreenHeader),
      }, header),
      div({
        className: classNames('OffScreenMenu_main', css.offScreenMain),
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
        className: classNames('OffScreenMenu_footer', css.offScreenFooter),
      }, languagesMobile),
    ]));
  }
}

const { arrayOf, bool, node, object, oneOfType, shape, string } = PropTypes;

OffScreenMenu.propTypes = {
  color: string.isRequired,
  isOpen: bool.isRequired,
  menuLinksTitle: string.isRequired,
  menuLinks: arrayOf(
    shape({
      active: bool.isRequired,
      activeColor: string.isRequired,
      content: string.isRequired,
      href: string.isRequired,
      type: string.isRequired,
      external: bool,
    })
  ).isRequired,
  userLinksTitle: string.isRequired,
  userLinks: arrayOf(
    shape({
      active: bool.isRequired,
      activeColor: string.isRequired,
      content: oneOfType([
        arrayOf(node),
        node,
      ]).isRequired,
      href: string.isRequired,
      type: string.isRequired,
    })
  ),
  languages: shape({
    name: string.isRequired,
    color: string.isRequired,
    links: arrayOf(
      shape({
        active: bool.isRequired,
        activeColor: string.isRequired,
        content: string.isRequired,
        href: string.isRequired,
      })),
  }),
  avatar: object, // eslint-disable-line react/forbid-prop-types
  newListingButton: object, // eslint-disable-line react/forbid-prop-types
  loginLinks: object, // eslint-disable-line react/forbid-prop-types
};

export default OffScreenMenu;
