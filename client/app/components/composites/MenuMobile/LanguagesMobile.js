import { Component, PropTypes } from 'react';
import r, { div, span } from 'r-dom';
import Link from '../../elements/Link/Link';
import css from './MenuMobile.css';
import globeIcon from './images/globeIcon.svg';
import variables from '../../../assets/styles/variables';

class LanguagesMobile extends Component {

  render() {
    const languages = this.props.links.map((link) => {
      const linkColor = link.active ?
        variables['--LanguagesMobile_textColorSelected'] :
        this.props.color || variables['--LanguagesMobile_textColorDefault'];
      return div(
        { className: `LanguagesMobile_languageLink ${css.languageLink}` },
        r(Link, { href: link.href, customColor: linkColor }, link.content));
    });

    return div({
      className: `MobileMenu_languages ${css.languages}`,
    }, [
      div({ className: `MenuSection_title ${css.menuSectionTitle}` }, [
        span({
          className: css.menuSectionIcon,
          dangerouslySetInnerHTML: {
            __html: globeIcon,
          } }),
        this.props.name]),
      div({ className: `LanguagesMobile_languageList ${css.languageList}` }, languages),
    ]);
  }
}

const { arrayOf, string } = PropTypes;

LanguagesMobile.propTypes = {
  name: string.isRequired,
  color: string.isRequired,
  links: arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
    })
  ).isRequired,
};

export default LanguagesMobile;
