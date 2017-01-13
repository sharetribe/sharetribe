/* eslint-disable react/no-set-state, no-magic-numbers */

import { Component } from 'react';
import r from 'r-dom';
import withProps from '../../Styleguide/withProps';
import ManageAvailabilityCalendar from './ManageAvailabilityCalendar';
import moment from 'moment';
import { isSameDay } from 'react-dates';

const { storiesOf } = storybookFacade;

const MOMENTJS_LOCALE = 'en';

const now = Date.now();
const day1 = moment(now + 24 * 60 * 60 * 1000);
const day2 = moment(now + 2 * 24 * 60 * 60 * 1000);

class ManageAvailabilityCalendarWrapper extends Component {
  constructor(props) {
    super(props);
    this.state = {
      visibleMonth: moment().startOf('month'),
      blockedDays: [],
      reservedDays: [day1, day2],
    };

    // Set the Moment.js locale globally for react-dates to apply i18n
    // to react-dates.
    moment.locale(MOMENTJS_LOCALE);
  }
  render() {

    const allow = (d) => {
      this.setState({
        blockedDays: this.state.blockedDays.filter((day) => !isSameDay(d, day)),
      });
    };

    const block = (d) => {
      this.setState({
        blockedDays: this.state.blockedDays.concat(d),
      });
    };

    return r(ManageAvailabilityCalendar, {
      initialMonth: this.state.visibleMonth,
      blockedDays: this.state.blockedDays,
      reservedDays: this.state.reservedDays,
      onDayAllowed: allow,
      onDayBlocked: block,
      onMonthChanged: (m) => {
        this.setState({ visibleMonth: m });
      },
    });
  }
}

storiesOf('Availability')
  .add('ManageAvailabilityCalendar', () =>
       withProps(ManageAvailabilityCalendarWrapper, {}));
