import { Component, PropTypes } from 'react';
import { div, img, p } from 'r-dom';

import css from './SearchPage.css';

class SearchPage extends Component {

  constructor(props, context) {
    super(props, context);
    this.listings = this.props.searchPage.get('listings') || [];
  }

  render() {
    return div({ className: css.searchPage }, [
      div({ className: css.listingContainer }, this.listings.map((l) =>
        div({
          className: css.listing,
          key: `card_${l.get('id')}`,
        }, [
          div({ className: css.squareWrapper },
            img({
              className: css.thumbnail,
              src: 'http://placehold.it/264x264',
            }),
          ),
          div({ className: css.info }, [
            p({ className: css.title }, l.get('title')),
          ]),
        ])
      )),
    ]);
  }
}

const { object } = PropTypes;

SearchPage.propTypes = {
  searchPage: object, // eslint-disable-line react/forbid-prop-types
};

export default SearchPage;
