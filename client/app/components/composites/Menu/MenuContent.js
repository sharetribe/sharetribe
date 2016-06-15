import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import _ from 'lodash';
import MenuItem from '../../elements/MenuItem/MenuItem';
import css from './Menu.css';

const normalizeIndex = function normalizeIndex(index, arrayLength) {
  return (index + arrayLength) % arrayLength;
};

class MenuContent extends Component {

  constructor(props, context) {
    super(props, context);

    _.bindAll(this, [
      'moveFocusUp',
      'movefocusDown',
      'handleKeys',
      'focusToMenuItem',
      'updateFocusIndexBy',
      'resolveElement',
    ]);

    this.state = { activeIndex: 0 };
  }

  moveFocusUp() {
    this.updateFocusIndexBy(-1);
  }

  movefocusDown() {
    this.updateFocusIndexBy(1);
  }

  updateFocusIndexBy(delta) {
    this.focusToMenuItem(this.state.activeIndex + delta);
  }

  focusToMenuItem(index) {
    const menuitems = this.menuContent.querySelectorAll('.menuitem');
    const selectedIndex = normalizeIndex(index, menuitems.length);

    this.setState({ activeIndex: selectedIndex }, () => { // eslint-disable-line react/no-set-state
      menuitems[selectedIndex].focus();
    });
  }

  handleKeys(e) {
    const keys = {
      ArrowDown: this.movefocusDown,
      ArrowUp: this.moveFocusUp,
      Escape: this.props.onCloseMenu,
    };

    if (keys[e.key]) {
      keys[e.key].call(this);
    }
  }

  resolveElement(data, index) {
    if (data.type === 'menuitem') {
      return Object.assign({},
        { ContentComponent: MenuItem },
        { props: Object.assign({}, data,
          {
            index,
            hoverFocus: this.focusToMenuItem,
          }),
        }
      );
    }
    return null;
  }

  render() {
    return (
      div(
        {
          tabIndex: '-1',
          style: { top: `${this.props.contentPos}px` },
          className: `menu__content ${css.menuContent}`,
          onKeyDown: this.handleKeys,
          ref: (c) => {
            this.menuContent = c;
          },
        }, [
          div({
            className: css.menuContentArrowBelow,
            style: { left: this.props.arrowPosition },
          }),
          div({
            className: css.menuContentArrowTop,
            style: { left: this.props.arrowPosition },
          }),
        ].concat(
          this.props.content.map((v, i) => {
            const elemData = this.resolveElement(v, i);
            return r(elemData.ContentComponent, elemData.props);
          })
        )
      )
    );
  }

}

const { arrayOf, bool, func, number, shape, string } = PropTypes;

MenuContent.propTypes = {
  content: arrayOf(
    shape({
      active: bool.isRequired,
      activeColor: string.isRequired,
      content: string.isRequired,
      href: string.isRequired,
      type: string.isRequired,
    })
  ).isRequired,
  contentPos: number.isRequired,
  arrowPosition: number.isRequired,
  onCloseMenu: func.isRequired,
  isOpen: bool.isRequired,
};

export default MenuContent;

