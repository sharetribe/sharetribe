/* eslint-disable react/no-set-state */

import { Component, PropTypes } from 'react';
import { form, input, button, span, div } from 'r-dom';
import * as placesUtils from '../../../utils/places';
import variables from '../../../assets/styles/variables';

import css from './SearchBar.css';
import icon from './images/search-icon.svg';

const SEARCH_MODE_KEYWORD = 'keyword';
const SEARCH_MODE_LOCATION = 'location';
const SEARCH_MODE_KEYWORD_AND_LOCATION = 'keyword_and_location';
const SEARCH_MODES = [
  SEARCH_MODE_KEYWORD,
  SEARCH_MODE_LOCATION,
  SEARCH_MODE_KEYWORD_AND_LOCATION,
];

class SearchBar extends Component {
  constructor(props) {
    super(props);

    // Bind `this` within methods
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleResize = this.handleResize.bind(this);

    this.state = {
      selectedPlace: null,
      mobileSearchOpen: false,
    };
  }
  componentDidMount() {
    document.body.classList.add(css.topLevelBody);
    window.addEventListener('resize', this.handleResize);

    if (!this.locationInput) {
      return;
    }
    const bounds = { north: -90, east: -180, south: 90, west: 180 };
    if (window.google) {
      const autocomplete = new window.google.maps.places.Autocomplete(this.locationInput, { bounds });
      autocomplete.setTypes(['geocode']);
      autocomplete.setFields(['address_components', 'geometry', 'icon', 'name']);
      this.placeChangedListener = window.google.maps.event.addListener(
        autocomplete,
        'place_changed',
        () => {
          this.setState({ selectedPlace: autocomplete.getPlace() });
        }
      );
    }
  }
  componentWillUnmount() {
    document.body.classList.remove(css.topLevelBody);
    window.removeEventListener('resize', this.handleResize);

    if (this.placeChangedListener) {
      this.placeChangedListener.remove();
    }

    // Clean up the generated autocompletion UI. Assumes there is only one.
    const container = document.body.querySelector('.pac-container');

    if (container) {
      document.body.removeChild(container);
    }
  }
  handleResize() {

    // We need to remove mobileSearchOpen state to get correct mode
    // when resizing browser window
    const searchFormBreakpoint = variables['--breakpointLarge'];
    if (window.matchMedia(`(min-width: ${searchFormBreakpoint}px)`).matches) {
      this.setState({ mobileSearchOpen: false });
    }
  }
  handleSubmit() {
    if (!this.keywordInput && !this.locationInput) {
      throw new Error('No input refs saved to submit SearchBar form');
    }

    this.setState({ mobileSearchOpen: false });

    const keywordValueStr = this.keywordInput ? this.keywordInput.value.trim() : '';
    const locationValueStr = this.locationInput ? this.locationInput.value.trim() : '';

    const onSubmit = this.props.onSubmit;

    if (!this.locationInput) {
      // Only keyword input, submitting current input value
      onSubmit({
        keywordQuery: keywordValueStr,
        locationQuery: null,
        place: null,
      });
      return;
    }

    const keywordValue = this.keywordInput ? this.keywordInput.value : null;

    if (this.state.selectedPlace && this.state.selectedPlace.geometry) {
      // Place already selected, submitting selected value
      onSubmit({
        keywordQuery: keywordValue,
        locationQuery: locationValueStr,
        place: this.state.selectedPlace,
      });
    } else if (locationValueStr) {
      // Predict location from the typed value
      placesUtils.getPrediction(locationValueStr)
        .then((place) => {
          onSubmit({
            keywordQuery: keywordValue,
            locationQuery: locationValueStr,
            place,
          });
        })
        .catch((e) => {
          console.error('failed to predict location:', e); // eslint-disable-line no-console
          onSubmit({
            keywordQuery: keywordValue,
            locationQuery: locationValueStr,
            place: null,
            errorStatus: e.serviceStatus,
          });
        });
    } else {
      // Only keyword value present, submit that
      onSubmit({
        keywordQuery: keywordValue,
        locationQuery: '',
        place: null,
      });
    }
  }
  render() {
    const { mode, keywordPlaceholder, locationPlaceholder, keywordQuery, locationQuery } = this.props;

    // Custom color support disabled for now until further discussion.
    // const bgColor = customColor || variables['--SearchBar_mobileBackgroundColor'];
    // const bgColorDarkened = brightness(bgColor, 80);
    const bgColor = '#34495E';
    const bgColorDarkened = '#2C3E50 ';

    const keywordInput = input({
      type: 'search',
      className: css.keywordInput,
      placeholder: keywordPlaceholder,
      defaultValue: keywordQuery,
      ref: (c) => {
        this.keywordInput = c;
      },
    });
    const locationInput = input({
      type: 'search',
      className: css.locationInput,
      placeholder: locationPlaceholder,
      defaultValue: locationQuery,
      autoComplete: 'off',

      // When the user edits the selected location value, the fetched
      // place object is not up to date anymore and has to be cleared.
      onChange: () => this.setState({ selectedPlace: null }),

      ref: (c) => {
        this.locationInput = c;
      },

    });

    const hasKeywordInput = mode === SEARCH_MODE_KEYWORD || mode === SEARCH_MODE_KEYWORD_AND_LOCATION;
    const hasLocationInput = mode === SEARCH_MODE_LOCATION || mode === SEARCH_MODE_KEYWORD_AND_LOCATION;

    // Ugly, but we have to add the class to body since the Google
    // Maps Places Autocomplete .pac-container is within the body
    // element.
    if (typeof document === 'object' && document.body) {
      if (this.state.mobileSearchOpen) {
        if (!document.body.classList.contains(css.mobileSearchOpen)) {
          document.body.classList.add(css.mobileSearchOpen);
        }
      } else if (document.body.classList.contains(css.mobileSearchOpen)) {
        document.body.classList.remove(css.mobileSearchOpen);
      }
    }

    return div({
      className: css.root,
      classSet: {
        [css.root]: true,
        [css.mobileSearchOpen]: this.state.mobileSearchOpen,
      },
    }, [
      button({
        className: css.mobileToggle,
        onClick: () => this.setState({ mobileSearchOpen: !this.state.mobileSearchOpen }),
      }, [
        div({
          dangerouslySetInnerHTML: { __html: icon },
        }),
        span({
          className: css.mobileToggleArrow,
          style: {
            borderBottomColor: this.state.mobileSearchOpen ? bgColor : 'transparent',
          },
        }),
      ]),
      form({
        classSet: { [css.form]: true },
        onSubmit: (e) => {
          e.preventDefault();
          this.handleSubmit();
        },
        style: {
          backgroundColor: this.state.mobileSearchOpen ? bgColor : 'transparent',
        },
      }, [
        hasKeywordInput ? keywordInput : null,
        hasLocationInput ? locationInput : null,
        button({
          type: 'submit',
          className: css.searchButton,
          dangerouslySetInnerHTML: { __html: icon },
          style: {
            backgroundColor: this.state.mobileSearchOpen ? bgColorDarkened : 'transparent',
          },
        }),
        span({ className: css.focusContainer }),
      ]),
    ]);
  }
}

SearchBar.propTypes = {
  mode: PropTypes.oneOf(SEARCH_MODES).isRequired,
  keywordPlaceholder: PropTypes.string.isRequired,
  locationPlaceholder: PropTypes.string.isRequired,
  keywordQuery: PropTypes.string,
  locationQuery: PropTypes.string,
  onSubmit: PropTypes.func.isRequired,
  customColor: PropTypes.string,
};

export default SearchBar;
