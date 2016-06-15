import { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import r, { div } from 'r-dom';
import _ from 'lodash';

import MenuLabel from './MenuLabel';
import MenuLabelDropdown from './MenuLabelDropdown';
import MenuContent from './MenuContent';
import css from './Menu.css';

const MENUCONTENT_OVERLAP = 5;
const MENULABEL_MAP = {
  menu: MenuLabel,
  dropdown: MenuLabelDropdown,
};

class Menu extends Component {

  constructor(props, context) {
    super(props, context);

    _.bindAll(this, [
      'onContentToggle',
      'afterContentToggle',
      'closeMenu',
      'handleBlur',
    ]);

    this.state = {
      isOpen: this.props.isOpen,
      labelGetsFocus: false,
      contentPos: 80,
      arrowPosition: 50,
    };
  }

  componentDidMount() {
    const menuLabel = ReactDOM.findDOMNode(this.menuLabel);
    const verticalPos = menuLabel.offsetTop + menuLabel.offsetHeight - MENUCONTENT_OVERLAP;

    this.setState({ // eslint-disable-line react/no-did-mount-set-state, react/no-set-state
      contentPos: verticalPos,
      arrowPosition: menuLabel.offsetWidth / 2, // eslint-disable-line no-magic-numbers
    });
  }

  // When content dropdown has been closed, label should have focus
  componentDidUpdate() {
    const menuInDom = ReactDOM.findDOMNode(this);
    if (menuInDom.contains(document.activeElement) && this.state.labelGetsFocus) {
      ReactDOM.findDOMNode(this.menuLabel).focus();
    }
  }

  onContentToggle() {
    this.setState({ isOpen: !this.state.isOpen }, this.afterContentToggle); // eslint-disable-line react/no-set-state
  }

  afterContentToggle() {
    if (this.state.isOpen) {
      this.menuContent.focusToMenuItem(0);
    }
  }

  closeMenu() {
    this.setState({ isOpen: false, labelGetsFocus: true }); // eslint-disable-line react/no-set-state
  }

  handleBlur() {
    const that = this;

    // Give next element a tick to take the focus
    setTimeout(() => {
      const menuInDom = ReactDOM.findDOMNode(this);
      if (!menuInDom.contains(document.activeElement) && that.state.isOpen) {
        that.closeMenu();
      }
    }, 1);
  }

  render() {
    const requestedLabel = MENULABEL_MAP[this.props.menuLabelType];
    const LabelComponent = requestedLabel != null ? requestedLabel : null;

    return div({
      className: `menu ${css.menu}`,
      onBlur: this.handleBlur,
      tabIndex: '0',
    }, [
      r(LabelComponent,
        {
          key: `${this.props.identifier}_menulabel`,
          hasFocus: this.state.labelGetsFocus,
          isOpen: this.state.isOpen,
          onToggleActive: this.onContentToggle,
          name: this.props.name,
          ref: (c) => {
            this.menuLabel = c;
          },
        }
      ),
      r(MenuContent,
        {
          key: `${this.props.identifier}_menucontent`,
          isOpen: this.state.isOpen,
          onCloseMenu: this.closeMenu,
          content: this.props.content,
          contentPos: this.state.contentPos,
          arrowPosition: this.state.arrowPosition,
          ref: (c) => {
            this.menuContent = c;
          },
        }
      ),
    ]);
  }
}

Menu.propTypes = {
  isOpen: PropTypes.bool,
  name: PropTypes.string.isRequired,
  identifier: PropTypes.string.isRequired,
  menuLabelType: PropTypes.string,
  content: PropTypes.arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
      type: PropTypes.string.isRequired,
    })
  ).isRequired,
};

export default Menu;
