import React, { Children, Component, PropTypes } from 'react';
import { div } from 'r-dom';
import classNames from 'classnames';
import css from './ListingCardPanel.css';


class ListingCardPanel extends Component {

  shouldComponentUpdate(nextProps) {
    return this.props.children !== nextProps.children;
  }

  render() {
    const childrenWithColumnStyle = Children.map(
      this.props.children,
      (child) => React.cloneElement(child, {
        className: css.card,
      })
    );

    return div({
      className: classNames('ListingCardPanel', css.panel, this.props.className),
    }, childrenWithColumnStyle);
  }
}


const { arrayOf, node, oneOfType, string } = PropTypes;

ListingCardPanel.propTypes = {
  children: oneOfType([
    arrayOf(node),
    node,
  ]),
  className: string,
};

export default ListingCardPanel;
