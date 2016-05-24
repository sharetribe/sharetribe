import { Component, PropTypes } from 'react';
import { form, input, button, span } from 'r-dom';

import css from './SearchBar.css';
import icon from './images/search-icon.svg';

const SEARCH_MODE_KEYWORD = 'keyword';
const SEARCH_MODE_LOCATION = 'location';
const SEARCH_MODE_KEYWORD_AND_LOCATION = 'keyword-and-location';
const SEARCH_MODES = [
  SEARCH_MODE_KEYWORD,
  SEARCH_MODE_LOCATION,
  SEARCH_MODE_KEYWORD_AND_LOCATION,
];

class SearchBar extends Component {
  constructor(props) {
    super(props);

    // The values of the inputs are synced to the component state
    // until the form is submitted.
    this.state = {
      keyword: '',
      location: '',
    };
  }
  render() {
    const { mode, keywordPlaceholder, locationPlaceholder } = this.props;

    const keywordInput = input({
      type: 'search',
      className: css.keywordInput,
      placeholder: keywordPlaceholder,
      onChange: (e) => this.setState({ keyword: e.target.value }), // eslint-disable-line react/no-set-state
    });
    const locationInput = input({
      type: 'search',
      className: css.locationInput,
      placeholder: locationPlaceholder,
      autoComplete: 'off',
      onChange: (e) => this.setState({ location: e.target.value }), // eslint-disable-line react/no-set-state
    });

    const hasKeywordInput = mode === SEARCH_MODE_KEYWORD || mode === SEARCH_MODE_KEYWORD_AND_LOCATION;
    const hasLocationInput = mode === SEARCH_MODE_LOCATION || mode === SEARCH_MODE_KEYWORD_AND_LOCATION;

    return form({
      classSet: { [css.root]: true },
      onSubmit: (e) => {
        e.preventDefault();
        this.props.onSubmit(this.state);
      },
    }, [
      hasKeywordInput ? keywordInput : null,
      hasLocationInput ? locationInput : null,
      button({
        type: 'submit',
        className: css.searchButton,
        dangerouslySetInnerHTML: { __html: icon },
      }),
      span({ className: css.focusContainer }),
    ]);
  }
}

SearchBar.propTypes = {
  mode: PropTypes.oneOf(SEARCH_MODES).isRequired,
  keywordPlaceholder: PropTypes.string.isRequired,
  locationPlaceholder: PropTypes.string.isRequired,
  onSubmit: PropTypes.func.isRequired,
};

export default SearchBar;
