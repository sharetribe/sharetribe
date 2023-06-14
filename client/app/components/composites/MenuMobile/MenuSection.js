import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import css from './MenuMobile.css';
import MenuItem from '../../elements/MenuItem/MenuItem';

class MenuSection extends Component {

  resolveElement(data, index, textColor) {
    if (data.type === 'menuitem') {
      return Object.assign({},
        { ContentComponent: MenuItem },
        { props: Object.assign({}, data, {
          index,
          textColor,
          extraClasses: css.menuSectionMenuItem,
          extraClassesLink: css.menuSectionMenuItemLink,
        }) }
      );
    }
    return null;
  }

  render() {
    const links = this.props.links ?
      this.props.links.map((v, i) => {
        const elemData = this.resolveElement(v, i, this.props.color);
        return r(elemData.ContentComponent, elemData.props);
      }) :
      [];

    return links.length > 0 ?
      div({
        className: `MenuSection ${css.menuSection}`,
      }, [
        div({ className: `MenuSection_title ${css.menuSectionTitle}` }, this.props.name),
      ].concat(links)) :
      null;
  }
}

const { arrayOf, bool, node, oneOfType, string } = PropTypes;

MenuSection.propTypes = {
  name: string.isRequired,
  color: string.isRequired,
  links: arrayOf(
    PropTypes.shape({
      active: bool.isRequired,
      activeColor: string.isRequired,
      content: oneOfType([
        arrayOf(node),
        node,
      ]).isRequired,
      href: string.isRequired,
      type: string.isRequired,
      external: bool,
    })
  ),
};

export default MenuSection;
