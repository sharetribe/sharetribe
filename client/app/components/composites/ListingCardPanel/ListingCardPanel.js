import React, { Children, Component, PropTypes } from 'react';
import r, { div } from 'r-dom';
import classNames from 'classnames';
import PageSelection from '../../composites/PageSelection/PageSelection';
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

    return div(
      {
        className: classNames('ListingCardPanel', css.container, this.props.className),
      },
      [
        div(
          {
            className: classNames('ListingCardPanel_listings', css.panel),
          },
          childrenWithColumnStyle),
        r(PageSelection,
          {
            className: css.responsivePadding,
            currentPage: this.props.currentPage,
            totalPages: this.props.totalPages,
            location: this.props.location,
            pageParam: this.props.pageParam,
          }),
      ]);
  }
}


const { arrayOf, oneOfType, node, number, string } = PropTypes;

ListingCardPanel.propTypes = {
  children: oneOfType([
    arrayOf(node),
    node,
  ]),
  className: string,
  currentPage: number,
  totalPages: number,
  location: string,
  pageParam: string,
};

export default ListingCardPanel;
