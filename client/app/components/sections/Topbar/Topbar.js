import { Component, PropTypes } from 'react';
import r, { div } from 'r-dom';

import css from './Topbar.css';

import Logo from '../../elements/Logo/Logo';
import SearchBar from '../../composites/SearchBar/SearchBar';

class Topbar extends Component {
  render() {
    return div({ className: css.topbar }, [
      r(Logo, { ...this.props.logo, classSet: css.topbarLogo }),
      this.props.search ?
        r(SearchBar, {
          mode: this.props.search.mode,
          keywordPlaceholder: this.props.search.keyword_placeholder,
          locationPlaceholder: this.props.search.location_placeholder,
          onSubmit: (data) => {
            // TODO: submit with actual data
            console.log(data); // eslint-disable-line no-console
          },
        }) :
        null,
    ]);
  }
}

Topbar.propTypes = {
  logo: PropTypes.shape(Logo.propTypes).isRequired,
  search: PropTypes.shape({
    mode: PropTypes.string,
    keyword_placeholder: PropTypes.string,
    location_placeholder: PropTypes.string,
  }),
};

export default Topbar;
