/* eslint-disable react/no-set-state */

import { Component, PropTypes } from 'react';
import { form, input, button, span, div } from 'r-dom';

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

const coordinates = (place) => {
  if (place && place.geometry) {
    return place.geometry.location.toUrlValue();
  }
  return null;
};

const getDetails = (placeId) => new Promise((resolve, reject) => {
  const serviceStatus = window.google.maps.places.PlacesServiceStatus;
  const el = document.createElement('div');
  const service = new window.google.maps.places.PlacesService(el);

  service.getDetails({ placeId }, (place, status) => {
    if (status !== serviceStatus.OK) {
      reject(new Error(`Could not get details for place id "${placeId}"`));
    } else {
      resolve(place);
    }
  });
});

const getPrediction = (location) => new Promise((resolve, reject) => {
  const serviceStatus = window.google.maps.places.PlacesServiceStatus;
  const service = new window.google.maps.places.AutocompleteService();

  service.getPlacePredictions({ input: location }, (predictions, status) => {
    if (status !== serviceStatus.OK) {
      reject(new Error(`Prediction service status not OK: ${status}`));
    } else if (predictions.length === 0) {
      reject(new Error(`No predictions found for location "${location}"`));
    } else {
      resolve(getDetails(predictions[0].place_id));
    }
  });
});

class SearchBar extends Component {
  constructor(props) {
    super(props);

    // Bind `this` within methods
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleResize = this.handleResize.bind(this);

    this.state = {
      selectedPlace: null,
      mobileMenuOpen: false,
    };
  }
  componentDidMount() {
    document.body.classList.add(css.topLevelBody);
    window.addEventListener('resize', this.handleResize);

    if (!this.locationInput) {
      return;
    }
    const bounds = { north: -90, east: -180, south: 90, west: 180 };
    const autocomplete = new window.google.maps.places.Autocomplete(this.locationInput, { bounds });
    autocomplete.setTypes(['geocode']);
    this.placeChangedListener = window.google.maps.event.addListener(
      autocomplete,
      'place_changed',
      () => this.setState({ selectedPlace: autocomplete.getPlace() })
    );
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
    this.setState({ mobileMenuOpen: false });
  }
  handleSubmit() {
    if (!this.keywordInput && !this.locationInput) {
      throw new Error('No input refs saved to submit SearchBar form');
    }

    this.setState({ mobileMenuOpen: false });

    const keywordValueStr = this.keywordInput ? this.keywordInput.value.trim() : '';
    const locationValueStr = this.locationInput ? this.locationInput.value.trim() : '';

    if ((keywordValueStr + locationValueStr).length === 0) {
      // Skip submit when all inputs are empty
      return;
    }

    const onSubmit = this.props.onSubmit;

    if (!this.locationInput) {
      // Only keyword input, submitting current input value
      onSubmit({
        keyword: keywordValueStr,
        location: null,
        coordinates: null,
      });
      return;
    }

    const keywordValue = this.keywordInput ? this.keywordInput.value : null;
    const coords = coordinates(this.state.selectedPlace);

    if (coords) {
      // Place already selected, submitting selected value
      onSubmit({
        keyword: keywordValue,
        location: locationValueStr,
        coordinates: coords,
      });
    } else if (locationValueStr) {
      // Predict location from the typed value
      getPrediction(locationValueStr)
        .then((place) => {
          const predictedCoords = coordinates(place);
          if (!predictedCoords) {
            throw new Error(`Could not get coordinates from place predicted from location "${locationValueStr}"`);
          }
          onSubmit({
            keyword: keywordValue,
            location: locationValueStr,
            coordinates: predictedCoords,
          });
        })
        .catch((e) => {
          console.error('failed to predict location:', e); // eslint-disable-line no-console
        });
    } else if (this.keywordInput) {
      // Only keyword value present, submit that
      onSubmit({
        keyword: keywordValue,
        location: '',
        coords: null,
      });
    }
  }
  render() {
    const { mode, keywordPlaceholder, locationPlaceholder } = this.props;

    const keywordInput = input({
      type: 'search',
      className: css.keywordInput,
      placeholder: keywordPlaceholder,
      ref: (c) => {
        this.keywordInput = c;
      },
    });
    const locationInput = input({
      type: 'search',
      className: css.locationInput,
      placeholder: locationPlaceholder,
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
      document.body.classList.toggle(css.mobileMenuOpen, this.state.mobileMenuOpen);
    }

    return div({
      className: css.root,
      classSet: {
        [css.root]: true,
        [css.mobileMenuOpen]: this.state.mobileMenuOpen,
      },
    }, [
      button({
        className: css.mobileToggle,
        onClick: () => this.setState({ mobileMenuOpen: !this.state.mobileMenuOpen }),
        dangerouslySetInnerHTML: { __html: icon },
      }),
      form({
        classSet: { [css.form]: true },
        onSubmit: (e) => {
          e.preventDefault();
          this.handleSubmit();
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
      ]),
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
