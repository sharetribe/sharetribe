/* eslint-disable react/no-set-state */

import React from 'react';
import PropTypes from 'prop-types';
import moment from 'moment';
import 'react-dates/initialize';
import { DayPicker, isSameDay, isInclusivelyBeforeDay } from 'react-dates';

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
    enableOutsideDays: true,
    numberOfMonths: 1,
    hideKeyboardShortcutsPanel: true,
    // eslint-disable-next-line react/display-name
    renderDayContents: (day) => {
      const isPreviousDay = day.isBefore(moment(), 'day');
      const currentDay = isSameDay(moment(), day);
      const dayBlocked = isBlocked(props.blockedDays, day);
      const dayReserved = isReserved(props.reservedDays, day);
      const pastDayClass = isPreviousDay ? ' calendar-day-past ' : '';
      const todayClass = currentDay ? ' calendar-day-today ' : '';
      const blockedClass = dayBlocked ? ' calendar-day-blocked ' : '';
      const reservedClass = dayReserved ? ' calendar-day-reserved' : '';

      return (
          <span className={`${pastDayClass}${todayClass}${blockedClass}${reservedClass}`}>
              <span className='calendar-day-date'>
                {day.format('D')}
              </span>
          </span>
      );
    },
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

  return (
      <div className={`${css.root} ${props.extraClasses || ''}`}>
        <DayPicker {...pickerProps} />
      </div>
  );
};

ManageAvailabilityCalendar.propTypes = {
  // eslint-disable-next-line react/forbid-prop-types
  initialMonth: PropTypes.object.isRequired,
  blockedDays: PropTypes.arrayOf(PropTypes.object).isRequired,
  reservedDays: PropTypes.arrayOf(PropTypes.object).isRequired,
  onDayAllowed: PropTypes.func.isRequired,
  onDayBlocked: PropTypes.func.isRequired,
  onMonthChanged: PropTypes.func.isRequired,
  extraClasses: PropTypes.string,
};

export default ManageAvailabilityCalendar;
