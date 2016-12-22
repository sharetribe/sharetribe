import { PropTypes } from 'react';
import { connect } from 'react-redux';
import { bindActionCreators } from 'redux';
import r from 'r-dom';
import ManageAvailability from './ManageAvailability';
import * as availabilityReducer from '../../../reducers/ManageAvailabilityReducer';
import * as FlashNotificationActions from '../../../actions/FlashNotificationActions';
import * as ManageAvailabilityActions from '../../../actions/ManageAvailabilityActions';

const ManageAvailabilityContainer = ({
  availability_link,
  header,
  actions,
  flashNotifications,
  isOpen,
  visibleMonth,
  hasChanges,
  saveInProgress,
  saveFinished,
  reservedDays,
  blockedDays,
  sideWinderWrapper,
}) =>
      r(ManageAvailability, {
        hasChanges,
        saveInProgress,
        saveFinished,
        onOpen: actions.openEditView,
        onSave: actions.saveChanges,
        isOpen,
        actions,
        availability_link,
        flashNotifications,
        header,
        calendar: {
          initialMonth: visibleMonth,
          blockedDays,
          reservedDays,
          onDayAllowed: actions.unblockDay,
          onDayBlocked: actions.blockDay,
          onMonthChanged: actions.changeMonth,
        },
        sideWinderWrapper,
      });

const { arrayOf, bool, func, object, shape } = PropTypes;

/* eslint-disable react/forbid-prop-types */

ManageAvailabilityContainer.propTypes = {
  // from ManageAvailabilityApp
  availability_link: object,
  header: object.isRequired,

  // actions
  actions: shape({
    openEditView: func.isRequired,
    saveChanges: func.isRequired,
    closeEditView: func.isRequired,
    unblockDay: func.isRequired,
    blockDay: func.isRequired,
    changeMonth: func.isRequired,
  }).isRequired,

  // from mapStateToProps
  isOpen: bool.isRequired,
  visibleMonth: object.isRequired,
  hasChanges: bool.isRequired,
  reservedDays: arrayOf(object).isRequired,
  blockedDays: arrayOf(object).isRequired,
};

/* eslint-enable react/forbid-prop-types */

const mapStateToProps = ({ flashNotifications, manageAvailability }) => ({
  flashNotifications,
  isOpen: manageAvailability.get('isOpen'),
  visibleMonth: manageAvailability.get('visibleMonth'),
  hasChanges: availabilityReducer.hasChanges(manageAvailability),
  saveInProgress: manageAvailability.get('saveInProgress'),
  saveFinished: manageAvailability.get('saveFinished'),
  reservedDays: manageAvailability.get('bookings').toJS(),
  blockedDays: availabilityReducer.blockedDays(manageAvailability).toJS(),
});

const mapDispatchToProps = (dispatch) => ({
  actions: bindActionCreators({ ...FlashNotificationActions, ...ManageAvailabilityActions }, dispatch),
});

export default connect(mapStateToProps, mapDispatchToProps)(ManageAvailabilityContainer);
