import { Component, PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import * as FlashNotificationActions from '../../../actions/FlashNotificationActions';
import * as ListingWorkingHoursActions from './actions';
import r, { div, a } from 'r-dom';
import Immutable from 'immutable';
import { t } from '../../../utils/i18n';
import { canUseDOM, canUsePushState } from '../../../utils/featureDetection';
import SideWinder from '../../composites/SideWinder/SideWinder';
import ManageAvailabilityHeader from '../../composites/ManageAvailabilityHeader/ManageAvailabilityHeader';
import FlashNotification from '../../composites/FlashNotification/FlashNotification';
import * as cssVariables from '../../../assets/styles/variables';

import ListingWorkingHoursForm from './form.js';

import css from './ListingWorkingHours.css';

const setPushState = (state, title, path) => {
  if (canUseDOM && canUsePushState) {
    window.history.pushState(state, title, path);
  } else if (canUseDOM) {
    window.location.hash = path;
  }
};


class ListingWorkingHours extends Component {
  constructor(props) {
    super(props);
    this.state = {
      renderCalendar: false,
      viewportHeight: null,
    };

    this.clickHandler = this.clickHandler.bind(this);
    this.resizeHandler = this.resizeHandler.bind(this);
  }

  componentDidMount() {

    if (this.props.availability_link) {
      this.props.availability_link.addEventListener('click', this.clickHandler);
    }

    this.setState({ viewportHeight: window.innerHeight }); // eslint-disable-line react/no-set-state
    window.addEventListener('resize', this.resizeHandler);
  }

  componentWillUpdate(nextProps) {
    // manage location hash
    const containsHash = window.location.hash.indexOf(`#${ListingWorkingHoursActions.EDIT_VIEW_OPEN_HASH}`) >= 0;
    const href = window.location.href;
    const paramsIndex = href.indexOf('?');
    const searchPart = paramsIndex >= 0 ? href.substring(paramsIndex) : '';

    if (nextProps.isOpen && !containsHash) {
      const openPath = `${window.location.pathname}#${ListingWorkingHoursActions.EDIT_VIEW_OPEN_HASH}${searchPart}`;
      setPushState(null, 'Listing working hours is open', openPath);
    } else if (!nextProps.isOpen && containsHash) {
      setPushState(null, 'Listing working hours is closed', `${window.location.pathname}${searchPart}`);
    }
  }

  componentWillUnmount() {
    window.removeEventListener('resize', this.resizeHandler);
    if (this.props.availability_link) {
      this.props.availability_link.removeEventListener('click', this.clickHandler);
    }
  }

  clickHandler(e) {
    e.preventDefault();
    this.props.actions.openEditView();
  }

  resizeHandler() {
    this.setState({ viewportHeight: window.innerHeight }); // eslint-disable-line react/no-set-state
  }

  render() {

    const defaultLink = a({
      href: '#',
      onClick: this.clickHandler,
    }, t('web.listings.edit_listing_availability'));
    const maybeRenderDefaultLink = this.props.availability_link ? null : defaultLink;

    const winder = {
      wrapper: this.props.sideWinderWrapper,
      maxWidth: cssVariables['--ManageAvailabilityWorkingHours_maxWidth'],
      minWidth: cssVariables['--ManageAvailability_minWidth'],
      height: this.state.viewportHeight,
      isOpen: this.props.isOpen,
      onClose: () => {
        if (this.props.saveInProgress) {
          return;
        }
        const explanation = t('web.listings.confirm_discarding_unsaved_availability_changes_explanation');
        const question = t('web.listings.confirm_discarding_unsaved_availability_changes_question');
        const text = `${explanation}\n\n${question}`;

        if (!this.props.hasChanges || window.confirm(text)) { // eslint-disable-line no-alert
          this.props.actions.closeEditView();
          if (typeof this.props.onCloseCallback === 'function') {
            this.props.onCloseCallback();
          }
        }
      },
    };


    return div([
      maybeRenderDefaultLink,
      r(SideWinder, winder, [
        div({ className: css.content }, [
          r(ManageAvailabilityHeader, this.props.header),
          r(ListingWorkingHoursForm, {
            workingTimeSlots: this.props.workingTimeSlots,
            time_slot_options: this.props.time_slot_options,
            day_names: this.props.day_names,
            actions: this.props.actions,
            saveInProgress: this.props.saveInProgress,
            saveFinished: this.props.saveFinished,
            hasChanges: this.props.hasChanges,
          }) : null,
        ]),
      ]),
      r(FlashNotification, {
        actions: this.props.actions,
        messages: this.props.flashNotifications,
      }),
    ]);
  }
}

ListingWorkingHours.propTypes = {
  actions: PropTypes.shape({
    removeFlashNotification: PropTypes.func.isRequired,
    openEditView: PropTypes.func.isRequired,
    closeEditView: PropTypes.func.isRequired,
    saveChanges: PropTypes.func.isRequired,
    dataChanged: PropTypes.func.isRequired,
  }).isRequired,
  availability_link: PropTypes.object, // eslint-disable-line react/forbid-prop-types
  flashNotifications: PropTypes.instanceOf(Immutable.List).isRequired,
  hasChanges: PropTypes.bool.isRequired,
  saveInProgress: PropTypes.bool.isRequired,
  saveFinished: PropTypes.bool.isRequired,
  onCloseCallback: PropTypes.func,
  isOpen: PropTypes.bool.isRequired,
  header: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  sideWinderWrapper: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  workingTimeSlots: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  time_slot_options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  day_names: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
};

// export default ListingWorkingHours;

const mapStateToProps = ({ flashNotifications, listingWorkingHours }) => ({
  flashNotifications,
  isOpen: listingWorkingHours.get('isOpen'),
  hasChanges: listingWorkingHours.get('changes'),
  saveInProgress: listingWorkingHours.get('saveInProgress'),
  saveFinished: listingWorkingHours.get('saveFinished'),
  workingTimeSlots: listingWorkingHours.get('workingTimeSlots'),
});

const mapDispatchToProps = (dispatch) => ({
  actions: bindActionCreators({ ...FlashNotificationActions, ...ListingWorkingHoursActions }, dispatch),
});

export default connect(mapStateToProps, mapDispatchToProps)(ListingWorkingHours);
