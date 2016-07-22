import { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import r, { div, a } from 'r-dom';
import _ from 'lodash';
import classNames from 'classnames';
import { canUseDOM } from '../../../utils/featureDetection';

import Menu from '../Menu/Menu';
import css from './MenuPriority.css';

const EXTRA_SPACING_RIGHT = 24;
const LINK_SPACING = 18;
const ROUNDING_ERROR_MARGIN = 2;

class MenuPriority extends Component {

  constructor(props, context) {
    super(props, context);

    this.links = _.sortBy(this.props.content, ['priority']);
    this.componentDidMount = this.componentDidMount.bind(this);
    this.updateWidths = this.updateWidths.bind(this);
    this.updateNav = this.updateNav.bind(this);

    this.state = {
      priorityWrapperWidth: '0px',
      priorityLinks: this.links.filter((l) => l.priority >= 0),
      hiddenLinks: this.links,
    };
  }

  componentDidMount() {
    if (canUseDOM) {
      const that = this;
      const priorityMenu = ReactDOM.findDOMNode(that);
      let linksWithBreakPoints = null;

      const menuIsVisible = function menuIsVisible(c) {
        // This is a naive check for visibility
        // PriorityMenu and its parent might change display settings due to responsive layout
        return window.getComputedStyle(c, null).getPropertyValue('display') !== 'none' &&
          window.getComputedStyle(c.parentNode, null).getPropertyValue('display') !== 'none';
      };

      // Wait for a paint to be done before calculating offsetWidths and stuff
      // ComponentDidMount is called after React component is passed to DOM,
      // but painting is not necessarily ready yet at that point
      window.requestAnimationFrame(() => {
        if (linksWithBreakPoints == null && menuIsVisible(priorityMenu)) {
          linksWithBreakPoints = that.updateWidths(that.links);
          that.updateNav(linksWithBreakPoints);
        }
      });

      window.addEventListener('resize', () => {
        if (menuIsVisible(priorityMenu)) {
          if (linksWithBreakPoints == null) {
            linksWithBreakPoints = that.updateWidths(that.links);
          }
          that.updateNav(linksWithBreakPoints);
        }
      });
    }
  }

  updateWidths(links) {
    const component = document.querySelectorAll(`.${css.menuPriority}`)[0];
    const priorityLinksWrapper = component.querySelectorAll(`.${css.priorityLinks}`)[0];

    const linksFromRenderedDiv = Array.prototype.slice.call(priorityLinksWrapper.childNodes);
    const withWidths = linksFromRenderedDiv.map((l) => {
      const linkData = _.find(links, (link) => link.content === l.textContent);
      const breakPoint = l.offsetLeft + l.offsetWidth + LINK_SPACING;
      return Object.assign({}, linkData, { breakPoint });
    });
    return withWidths;
  }

  updateNav(links) {
    const piorityMenu = document.querySelectorAll(`.${css.menuPriority}`)[0];
    const menuButton = document.querySelectorAll(`.${css.hiddenLinks}`)[0];
    const menuButtonWidth = menuButton != null ? menuButton.offsetWidth : 0;
    const availableSpace = piorityMenu.offsetWidth - menuButtonWidth - EXTRA_SPACING_RIGHT;

    for (let i = 0; i < links.length; i++) {
      if (links[i].breakPoint > availableSpace) {
        const noPriorityLinks = this.links.filter((l) => l.priority < 0);
        const breakPoint = i > 0 ? links[i - 1].breakPoint + ROUNDING_ERROR_MARGIN : 0;
        this.setState({ // eslint-disable-line react/no-set-state
          priorityWrapperWidth: `${breakPoint}px`,
          priorityLinks: links.slice(0, i),
          hiddenLinks: noPriorityLinks.concat(links.slice(i, links.length)),
        });
        break;
      }
    }

    if (links[links.length - 1].breakPoint < availableSpace) {
      const breakPoint = links[links.length - 1].breakPoint + ROUNDING_ERROR_MARGIN;
      this.setState({ // eslint-disable-line react/no-set-state
        priorityWrapperWidth: `${breakPoint}px`,
        priorityLinks: links,
        hiddenLinks: [],
      });
    }
  }

  render() {
    // If break points have not been calculated, render the div outside of viewport
    // for the sake of getting the widths of different priority links.
    const isMeasured = this.state.priorityLinks.length > 0 && this.state.priorityLinks[0].breakPoint != null;
    const style = isMeasured ?
    {
      width: this.state.priorityWrapperWidth,
    } :
    {
      position: 'absolute',
      top: '-2000px',
      left: '-2000px',
      width: '100%',
    };

    const fallbackLabel = !isMeasured || this.state.priorityLinks.length === 0 ? { name: this.props.nameFallback, menuLabelType: this.props.menuLabelTypeFallback } : {};
    const extraMenuProps = Object.assign({ className: css.hiddenLinks, content: this.state.hiddenLinks }, fallbackLabel);
    const menuProps = Object.assign(Object.assign({}, this.props, extraMenuProps));

    return div({
      className: classNames('MenuPriority', css.menuPriority),
    }, [
      div({
        className: css.priorityLinks,
        style,
      }, this.state.priorityLinks.map((l) => (
        a({
          className: css.priorityLink,
          href: l.href,
        }, l.content)
      ))),
      this.state.hiddenLinks.length > 0 ?
        r(Menu, menuProps) :
        null,
    ]);
  }
}


MenuPriority.propTypes = {
  name: PropTypes.string.isRequired,
  nameFallback: PropTypes.string.isRequired,
  extraClassesLabel: PropTypes.string,
  identifier: PropTypes.string.isRequired,
  menuLabelType: PropTypes.string,
  menuLabelTypeFallback: PropTypes.string,
  content: PropTypes.arrayOf(
    PropTypes.shape({
      active: PropTypes.bool.isRequired,
      activeColor: PropTypes.string.isRequired,
      content: PropTypes.string.isRequired,
      href: PropTypes.string.isRequired,
      priority: PropTypes.number.isRequired,
      type: PropTypes.string.isRequired,
    })
  ).isRequired,
};

export default MenuPriority;
