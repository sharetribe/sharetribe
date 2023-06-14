import { Component, PropTypes } from 'react';
import ReactDOM from 'react-dom';
import r, { div, a } from 'r-dom';
import _ from 'lodash';
import classNames from 'classnames';
import { canUseDOM } from '../../../utils/featureDetection';
import variables from '../../../assets/styles/variables';

import Menu from '../Menu/Menu';
import css from './MenuPriority.css';

const EXTRA_SPACING_RIGHT = variables['--MenuPriority_extraSpacingNoUnit'];
const LINK_SPACING = variables['--MenuPriority_itemSpacingNoUnit'];
const ROUNDING_ERROR_MARGIN = 2;

class MenuPriority extends Component {

  constructor(props, context) {
    super(props, context);

    this.links = _.sortBy(this.props.content, ['priority']);
    this.handleResize = this.handleResize.bind(this);
    this.updateWidths = this.updateWidths.bind(this);
    this.updateNav = this.updateNav.bind(this);

    this.state = {
      priorityWrapperWidth: '0px',
      priorityLinks: this.links.filter((l) => l.priority >= 0),
      hiddenLinks: this.links,
      linksWithBreakPoints: null,
    };
  }

  componentDidMount() {
    if (canUseDOM) {

      // Wait for a paint to be done before calculating offsetWidths and stuff
      // ComponentDidMount is called after React component is passed to DOM,
      // but painting is not necessarily ready yet at that point
      if (typeof window.requestAnimationFrame === 'function') {
        window.requestAnimationFrame(() => {
          this.handleResize();
        });
      } else {
        this.handleResize();
      }

      window.addEventListener('resize', this.handleResize);
    }
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.handleResize);
  }

  handleResize() {
    const priorityMenu = this.menuPriorityMounted;

    // If priorityMenu has not been mounted, do not update anything
    if (priorityMenu == null) {
      return;
    }

    // This is a naive check for visibility
    // PriorityMenu and its parent might change display settings due to responsive layout
    const menuIsVisible = window.getComputedStyle(priorityMenu, null).getPropertyValue('display') !== 'none' &&
      window.getComputedStyle(priorityMenu.parentNode, null).getPropertyValue('display') !== 'none';

    if (menuIsVisible) {
      if (this.state.linksWithBreakPoints == null) {
        this.setState({ linksWithBreakPoints: this.updateWidths(this.links) }); // eslint-disable-line react/no-set-state
      }
      this.updateNav(this.state.linksWithBreakPoints);
    }
  }

  updateWidths(links) {
    const linksFromRenderedDiv = Array.prototype.slice.call(this.priorityLinksMounted.childNodes);
    const withWidths = linksFromRenderedDiv.map((l) => {
      const linkData = _.find(links, (link) => l.dataset && l.dataset.pid === `${link.content} ${link.priority}`);
      const breakPoint = l.offsetLeft + l.offsetWidth + LINK_SPACING;
      return Object.assign({}, linkData, { breakPoint });
    });
    return withWidths;
  }

  updateNav(linksParam) {
    const links = linksParam || [];
    const menuButtonDOMNode = ReactDOM.findDOMNode(this.hiddenLinksMounted);
    const menuButtonWidth = menuButtonDOMNode != null ? menuButtonDOMNode.offsetWidth : 0;
    const availableSpace = this.menuPriorityMounted.offsetWidth - menuButtonWidth - EXTRA_SPACING_RIGHT;

    let i = 0;
    for (i = 0; i < links.length; i++) {
      if (links[i].breakPoint > availableSpace || (this.props.limitPriorityLinks != null && this.props.limitPriorityLinks >= 0 && i >= this.props.limitPriorityLinks)) {
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

    if (i === links.length && links[links.length - 1] && links[links.length - 1].breakPoint < availableSpace) {
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

    const useFallback = !isMeasured || this.state.priorityLinks.length === 0;
    const fallbackLabel = useFallback ? { name: this.props.nameFallback, menuLabelType: this.props.menuLabelTypeFallback } : {};
    const extraMenuProps = Object.assign({
      className: css.hiddenLinks,
      content: this.state.hiddenLinks,
      ref: (c) => {
        this.hiddenLinksMounted = c;
      },
    }, fallbackLabel);
    const menuProps = Object.assign(Object.assign({}, this.props, extraMenuProps));

    return div({
      className: classNames('MenuPriority', css.menuPriority, { [css.isMeasured]: isMeasured, [css.noPriorityLinks]: useFallback }),
      ref: (c) => {
        this.menuPriorityMounted = c;
      },
    }, [
      div({
        className: css.priorityLinks,
        style,
        ref: (c) => {
          this.priorityLinksMounted = c;
        },
      }, this.state.priorityLinks.map((l) => (
        a({
          'data-pid': `${l.content} ${l.priority}`,
          className: css.priorityLink,
          href: l.href,
          target: l.external ? '_blank' : null,
          rel: l.external ? 'noopener noreferrer' : null,
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
  limitPriorityLinks: PropTypes.number,
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
      external: PropTypes.bool,
    })
  ).isRequired,
};

export default MenuPriority;
