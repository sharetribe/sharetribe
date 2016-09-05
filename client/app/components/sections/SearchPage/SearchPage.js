import { Component, PropTypes } from 'react';
import { div, img, p } from 'r-dom';
import Immutable from 'immutable';

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


// These will change when DiscoveryAPI is ready
export const ListingModel = Immutable.Record({
  id: 'uuid',
  title: 'Listing',
});

export const SearchPageModel = Immutable.Record({
  prevPage: new Immutable.List(),
  currentPage: new Immutable.List(),
  nextPage: new Immutable.List(),
  listings: new Immutable.List(),
});

const { instanceOf } = PropTypes;

SearchPage.propTypes = {
  searchPage: instanceOf(SearchPageModel).isRequired,
};

export default SearchPage;
