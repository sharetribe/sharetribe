import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import css from './MenuMobile.css';
import MenuSection from './MenuSection';

class OffScreenMenu extends Component {

  render() {
    const isOpenClass = this.props.isOpen ? css.offScreenMenuOpen : '';

    return div({
      className: `OffScreenMenu ${css.offScreenMenu} ${isOpenClass}`,
    }, [
      div({
        className: `OffScreenMenu_header ${css.offScreenHeader}`,
      }, 'header'),
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
      }, 'footer'),
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
};

export default OffScreenMenu;
