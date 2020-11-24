/* eslint-disable react/no-set-state */

import { PropTypes } from 'react';
import r, { div } from 'r-dom';
import { DayPicker, isSameDay, isInclusivelyBeforeDay } from 'react-dates';
import moment from 'moment';

import 'react-dates/css/styles.scss';
import css from './ManageAvailabilityCalendar.css';

const isPast = (day) => {
  const today = moment();
  return !isSameDay(day, today) && isInclusivelyBeforeDay(day, today);
};

const isReserved = (reservedDays, day) =>
  !!reservedDays.find((d) => isSameDay(d, day));

const isBlocked = (blockedDays, day) =>
  !!blockedDays.find((d) => isSameDay(d, day));

const ManageAvailabilityCalendar = (props) => {

  const handleDayClick = (day) => {
    if (isReserved(props.reservedDays, day) || isPast(day)) {
      // Cannot allow or block a reserved or a past day
      return;
    } else if (isBlocked(props.blockedDays, day)) {
      props.onDayAllowed(day);
    } else {
      props.onDayBlocked(day);
    }
  };

  const pickerProps = {
    id: 'ManageAvailabilityCalendar_picker',
    enableOutsideDays: true,
    initialVisibleMonth: () => props.initialMonth,
    onDayClick: handleDayClick,
    onPrevMonthClick: () => {
      props.onMonthChanged(moment(props.initialMonth).subtract(1, 'months'));
    },
    onNextMonthClick: () => {
      props.onMonthChanged(moment(props.initialMonth).add(1, 'months'));
    },
    modifiers: {
      past: isPast,
      today: (d) => isSameDay(moment(), d),
      blocked: (d) => isBlocked(props.blockedDays, d),
      reserved: (d) => isReserved(props.reservedDays, d),
    },
  };

  return div({ className: `${css.root} ${props.extraClasses || ''}` }, [
    r(DayPicker, pickerProps),
  ]);
};

ManageAvailabilityCalendar.propTypes = {

  // moment.js instance
  initialMonth: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types

  // array of moment date instances
  blockedDays: PropTypes.arrayOf(PropTypes.object).isRequired,

  // array of moment date instances
  reservedDays: PropTypes.arrayOf(PropTypes.object).isRequired,

  onDayAllowed: PropTypes.func.isRequired,
  onDayBlocked: PropTypes.func.isRequired,
  onMonthChanged: PropTypes.func.isRequired,

  extraClasses: PropTypes.string,
};

export default ManageAvailabilityCalendar;
