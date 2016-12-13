import { Component, PropTypes } from 'react';
import r, { button, div, a } from 'r-dom';
import Immutable from 'immutable';
import classNames from 'classnames';
import { t } from '../../../utils/i18n';
import SideWinder from '../../composites/SideWinder/SideWinder';
import ManageAvailabilityHeader from '../../composites/ManageAvailabilityHeader/ManageAvailabilityHeader';
import ManageAvailabilityCalendar from '../../composites/ManageAvailabilityCalendar/ManageAvailabilityCalendar';
import FlashNotification from '../../composites/FlashNotification/FlashNotification';

import css from './ManageAvailability.css';

const CALENDAR_RENDERING_TIMEOUT = 100;

const SaveButton = (props) => button({
  className: classNames({
    [css.saveButton]: true,
    [css.saveButtonVisible]: props.isVisible,
  }),
  onClick: props.onClick,
}, t('web.listings.save_and_close_availability_editing'));

SaveButton.propTypes = {
  isVisible: PropTypes.bool.isRequired,
  onClick: PropTypes.func.isRequired,
};

/**
   Return `true` if component should load initial data.
*/
const shouldLoad = (isOpen, prevIsOpen) => isOpen && !prevIsOpen;

/**
   Load initial data if needed. This should happen only once when
   component `isOpen` becomes `true`
*/
const loadInitialDataIfNeeded = (props, prevProps = null) => {
  const isOpen = props.winder.isOpen;
  const prevIsOpen = prevProps && prevProps.winder.isOpen;

  if (shouldLoad(isOpen, prevIsOpen)) {
    props.calendar.onMonthChanged(props.calendar.initialMonth);
  }
};

class ManageAvailability extends Component {
  constructor(props) {
    super(props);
    this.state = { renderCalendar: false };

    this.clickHandler = this.clickHandler.bind(this);
  }

  componentDidMount() {
    // react-dates calendar height is often calculated incorrectly in
    // Safari when the SideWinder is shown. Rendering it
    // asynchronously allows the calendar to calculate the height
    // properly.
    // See: https://github.com/airbnb/react-dates/issues/46
    window.setTimeout(() => {
      this.setState({ renderCalendar: true }); // eslint-disable-line react/no-set-state
    }, CALENDAR_RENDERING_TIMEOUT);

    if (this.props.availability_link) {
      this.props.availability_link.addEventListener('click', this.clickHandler);
    }

    loadInitialDataIfNeeded(this.props);
  }

  componentDidUpdate(prevProps) {
    loadInitialDataIfNeeded(this.props, prevProps);
  }

  componentWillUnmount() {
    if (this.props.availability_link) {
      this.props.availability_link.removeEventListener('click', this.clickHandler);
    }
  }

  clickHandler(e) {
    e.preventDefault();
    this.props.onOpen();
  }

  render() {
    const showCalendar = this.props.winder.isOpen && this.state.renderCalendar;
    const defaultLink = a({
      href: '#',
      onClick: this.clickHandler,
    }, t('web.listings.edit_listing_availability'));
    const maybeRenderDefaultLink = this.props.availability_link ? null : defaultLink;

    return div([
      maybeRenderDefaultLink,
      r(SideWinder, this.props.winder, [
        div({ className: css.content }, [
          r(ManageAvailabilityHeader, this.props.header),
          showCalendar ? r(ManageAvailabilityCalendar, {
            ...this.props.calendar,
            extraClasses: css.calendar,
          }) : null,
          r(SaveButton, {
            isVisible: this.props.hasChanges,
            onClick: this.props.onSave,
          }),
        ]),
      ]),
      r(FlashNotification, {
        actions: this.props.actions,
        messages: this.props.flashNotifications,
      }),
    ]);
  }
}

ManageAvailability.propTypes = {
  actions: PropTypes.shape({
    removeFlashNotification: PropTypes.func.isRequired,
  }).isRequired,
  availability_link: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  flashNotifications: PropTypes.instanceOf(Immutable.List).isRequired,
  hasChanges: PropTypes.bool.isRequired,
  onOpen: PropTypes.func.isRequired,
  onSave: PropTypes.func.isRequired,
  winder: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  header: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  calendar: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
};

export default ManageAvailability;
