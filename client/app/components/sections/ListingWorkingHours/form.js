import React, { Component, PropTypes } from 'react';
import { Form, StyledSelect, FormField, Checkbox } from 'react-form';
import merge from 'lodash.merge';
import { t } from '../../../utils/i18n';
import * as convert from './convert';

import css from './form.css';
import loadingImage from './images/loading.svg';
import checkmarkImage from './images/checkmark.svg';
import minusCircle from './images/minus-circle.svg';

const RemoveIcon = () => (<span dangerouslySetInnerHTML={{ __html: minusCircle }} />); // eslint-disable-line react/no-danger

class TimeSlotWrapper extends Component {
  constructor(props) {
    super(props);
    this.state = {
      remove: false,
    };
    this.dayField = ['days', this.props.dayIndex];
    this.slotField = ['days', this.props.dayIndex, 'working_time_slots', this.props.index];
    this.handleRemove = this.handleRemove.bind(this);
    this.handleChanges = this.handleChanges.bind(this);
    this.timeSlotOptions = this.timeSlotOptions.bind(this);
  }

  getValue() {
    return this.props.formApi.getValue(this.slotField);
  }

  handleRemove(event) {
    event.preventDefault();
    this.setState({ remove: true }); // eslint-disable-line react/no-set-state
    const day = this.props.formApi.getValue(this.dayField);
    const slot = day.working_time_slots[this.props.index];
    if (slot.id) {
      slot._destroy = '1';  // eslint-disable-line no-underscore-dangle
    } else {
      day.working_time_slots.splice(this.props.index, 1);
    }
    if (day.working_time_slots.filter((x) => !x._destroy).length === 0) { // eslint-disable-line no-underscore-dangle
      day.enabled = false;
    }
    this.props.formApi.setValue(this.dayField, day);
    this.props.actions.dataChanged();
  }

  handleChanges(elem) {
    if (elem === 'from') {
      const slot = this.getValue();
      if (slot.from) {
        this.props.formApi.setValue(this.slotField.concat('till'), null, false);
      }
    }
    this.props.actions.dataChanged();
  }

  timeSlotOptions(elem) {
    if (elem === 'from') {
      const fromOptions = JSON.parse(JSON.stringify(this.props.time_slot_options));
      fromOptions.splice(-1, 1);
      return fromOptions;
    } else {
      const slot = this.getValue();
      const from = slot.from;
      let disable = true;
      if (slot.from) {
        const tillOptions = JSON.parse(JSON.stringify(this.props.time_slot_options));
        return tillOptions.map((o) => {
          o.disabled = disable; // eslint-disable-line no-param-reassign
          if (o.value === from) {
            disable = null;
          }
          return o;
        });
      } else {
        return [];
      }
    }
  }

  render() {
    const idPrefix = `days-${this.props.dayIndex}-working_time_slots-${this.props.index}`;

    return (
      <div>
        <div className={`timeSlot ${this.state.remove || this.context.remove ? 'hidden' : ''}`}>
          <div className="starTime">
            <span className="starTimeLabel">{t('web.listings.working_hours.start_time')}</span>
            <div className="timeSelect">
              <StyledSelect field={this.slotField.concat('from')}
                id={`${idPrefix}-from`} onChange={() => (this.handleChanges('from'))}
                options={this.timeSlotOptions('from')} placeholder={' '} />
            </div>
          </div>
          <div className="endTime">
            <span className="endTimeLabel">{t('web.listings.working_hours.end_time')}</span>
            <div className="timeSelect">
              <StyledSelect field={this.slotField.concat('till')}
                id={`${idPrefix}-till`} onChange={() => (this.handleChanges('till'))}
                options={this.timeSlotOptions('till')} placeholder={' '} />
            </div>
            <a className="remove" onClick={this.handleRemove}><RemoveIcon /></a>
          </div>
        </div>
      </div>
    );
  }
}
TimeSlotWrapper.propTypes = {
  timeSlot: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  index: PropTypes.number.isRequired,
  dayIndex: PropTypes.number.isRequired,
  time_slot_options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  actions: PropTypes.shape({
    dataChanged: PropTypes.func.isRequired,
  }).isRequired,
  formApi: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
};
TimeSlotWrapper.contextTypes = {
  remove: PropTypes.bool,
};

const TimeSlot = FormField(TimeSlotWrapper); // eslint-disable-line babel/new-cap

class DayWrapper extends Component {
  constructor(props) {
    super(props);
    this.state = {
      timeSlots: props.timeSlots,
      enabled: props.enabled,
    };
    this.handleAddMore = this.handleAddMore.bind(this);
    this.handleEnabled = this.handleEnabled.bind(this);
  }

  getChildContext() {
    return { remove: !this.props.enabled };
  }

  componentWillReceiveProps(nextProps) {
    this.setState({ // eslint-disable-line react/no-set-state
      timeSlots: nextProps.timeSlots,
      enabled: nextProps.enabled, // eslint-disable-line no-underscore-dangle
    });
  }

  newTimeSlot() {
    return { week_day: this.props.day, from: '09:00', till: '17:00' };
  }

  addSlot(timeSlot) {
    this.props.formApi.addValue(['days', this.props.index, 'working_time_slots'], timeSlot, false);
    this.props.actions.dataChanged();
  }

  handleAddMore(event) {
    event.preventDefault();
    this.addSlot({ week_day: this.props.day });
  }

  addDefaultTimeSlot() {
    if (this.state.timeSlots.length === 0) {
      this.addSlot(this.newTimeSlot());
    }
  }

  handleEnabled() {
    this.addDefaultTimeSlot();
    this.props.formApi.setValue(this.dayField, 'enabled', !this.props.enabled);
    this.props.actions.dataChanged();
  }

  render() {
    const dayIndex = this.props.index;
    const remove = !this.state.enabled;
    const options = this.props.time_slot_options;
    const timeSlots = this.props.timeSlots.map((timeSlot, index) => (
      <TimeSlot timeSlot={timeSlot} index={index} remove={remove}
        time_slot_options={options} key={index} actions={this.props.actions}
        dayIndex={dayIndex} formApi={this.props.formApi} />)
    );
    const fieldPrefix = ['days', dayIndex];

    return (
      <div className={css.weekDay} id={`week-day-${this.props.day}`}>
        <label className="title">
          <Checkbox field={fieldPrefix.concat('enabled')} id={`enable-${this.props.day}`} defaultValue='1' onChange={this.handleEnabled} />
          <span>{this.props.dayName}</span>
        </label>
        {timeSlots}
        <div className="addMore">
          <a className={this.state.enabled ? '' : 'hidden'} onClick={this.handleAddMore}>
          {t('web.listings.working_hours.add_another_time_slot')}
          </a>
        </div>
      </div>
    );
  }
}
DayWrapper.propTypes = {
  timeSlots: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  enabled: PropTypes.bool,
  day: PropTypes.string.isRequired,
  dayName: PropTypes.string.isRequired,
  index: PropTypes.number.isRequired,
  time_slot_options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  actions: PropTypes.shape({
    dataChanged: PropTypes.func.isRequired,
  }).isRequired,
  formApi: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
};
DayWrapper.childContextTypes = {
  remove: PropTypes.bool,
};

const Day = FormField(DayWrapper); // eslint-disable-line babel/new-cap

class SaveButton extends Component {
  render() {
    let html = null;

    if (this.props.saveInProgress) {
      html = loadingImage;
    } else if (this.props.saveFinished) {
      html = checkmarkImage;
    } else {
      html = t('web.listings.working_hours.save');
    }
    html = { __html: html };

    const buttonClass = `${css.saveButton} save-button ${this.props.saveFinished ? 'save-finished' : ''}`;

    return (
      <button className={buttonClass} disabled={this.props.saveInProgress || this.props.saveFinished}
        dangerouslySetInnerHTML={html} /> // eslint-disable-line react/no-danger
    );
  }
}
SaveButton.propTypes = {
  saveInProgress: PropTypes.bool.isRequired,
  saveFinished: PropTypes.bool.isRequired,
};

class ListingWorkingHoursForm extends Component {
  constructor(props) {
    super(props);
    this.handleSubmit = this.handleSubmit.bind(this);
    this.errorValidator = this.errorValidator.bind(this);
    this.formApi = null;
  }

  componentWillReceiveProps(nextProps) {
    if (this.formApi && nextProps.saveFinished) {
      this.formApi.setAllValues(nextProps.workingTimeSlots);
    }
  }

  renderWeekDays(formApi) {
    this.formApi = formApi;
    return formApi.values.days.map((dayData, index) => {
      const timeSlots = dayData.working_time_slots;
      const day = convert.weekDays()[index];
      const dayName = this.props.day_names[day];
      return (
        <div className="row" key={index}>
          <Day timeSlots={timeSlots} day={day} dayName={dayName} actions={this.props.actions}
            time_slot_options={this.props.time_slot_options} index={index} formApi={formApi}
            enabled={dayData.enabled} />
        </div>
      );
    });
  }

  handleSubmit(formData) {
    const dataToRails = convert.convertToApi(formData);
    this.props.actions.saveChanges(dataToRails);
  }

  errorValidator(values, field) {
    const currentDayIndex = field ? field[1] : null;
    const currentSlotIndex = field ? field[3] : null;
    const currentSlotProp = field ? field[4] : null;
    const currentSlot = field ? values.days[currentDayIndex].working_time_slots[currentSlotIndex] : null;
    const hourToInt = (hour) => {
      if (typeof hour === 'string') {
        const parsed = parseInt(hour.substr(0, 2), 10); // eslint-disable-line no-magic-numbers
        return isNaN(parsed) ? null : parsed;
      }
      return null;
    };
    const isEmpty = (value) => {
      const message = t('web.listings.errors.working_hours.required');
      return !value ? message : null;
    };

    // Continuous slots are allowed. Start time can equal with end time of other slot.
    const crossOtherSlot = (dayIndex, daySlots, slotIndex, fieldValue, prop) => {
      if (currentSlot && currentDayIndex === dayIndex && currentSlotIndex !== slotIndex) {
        return null;
      }
      const message = t('web.listings.errors.working_hours.overlaps');
      let intersection = false;
      daySlots.forEach((otherSlot, index) => {
        if (index === slotIndex) {
          return;
        }
        const otherFrom = hourToInt(otherSlot.from);
        const otherTill = hourToInt(otherSlot.till);
        const value = hourToInt(fieldValue);
        if (otherFrom !== null && otherTill !== null) {
          if (value &&
              ((prop === 'from' && otherFrom <= value && otherTill > value) ||
              (prop === 'till' && otherFrom < value && otherTill >= value))
            ) {
            intersection = true;
          }
        }
      });
      return intersection ? message : null;
    };
    const coversOtherSlot = (dayIndex, daySlots, slotIndex, slot) => {
      if (currentSlot && currentDayIndex === dayIndex && currentSlotIndex !== slotIndex) {
        return null;
      }
      const message = t('web.listings.errors.working_hours.covers');
      let covers = false;
      daySlots.forEach((otherSlot, index) => {
        if (index === slotIndex) {
          return;
        }
        const otherFrom = hourToInt(otherSlot.from);
        const otherTill = hourToInt(otherSlot.till);
        const from = hourToInt(slot.from);
        const till = hourToInt(slot.till);
        if (otherFrom !== null && otherTill !== null && from !== null && till !== null) {
          if (otherFrom >= from && otherTill <= till) {
            covers = true;
          }
        }
      });
      return covers ? message : null;
    };
    const validateDay = (day, dayIndex) => {
      const daySlots = day.working_time_slots;
      const slots = daySlots.map((slot, index) => {
        const slotErrors = {};
        slotErrors.from = isEmpty(slot.from) ||
          crossOtherSlot(dayIndex, daySlots, index, slot.from, 'from');
        if (currentSlotProp === null || currentSlotProp === 'till') {
          slotErrors.till = isEmpty(slot.till) ||
            crossOtherSlot(dayIndex, daySlots, index, slot.till, 'till');
        }
        const covers = coversOtherSlot(dayIndex, daySlots, index, slot);
        if (covers) {
          slotErrors.from = covers;
          slotErrors.till = covers;
        }
        return slotErrors;
      });
      return { working_time_slots: slots };
    };
    const days = [];
    values.days.forEach((day, index) => {
      days.push(validateDay(day, index));
    });
    const errors = { days: days }; // eslint-disable-line babel/object-shorthand
    if (currentSlot) {
      const prevErrors = JSON.parse(JSON.stringify(this.formApi.errors));
      const error = prevErrors.days[currentDayIndex].working_time_slots[currentSlotIndex];
      if (error) {
        error.from = null;
        error.till = null;
      }
      return merge(prevErrors, errors);
    } else {
      return errors;
    }
  }

  render() {
    const formClass = `working-hours-form ${this.props.hasChanges ? 'has-changes' : 'no-changes'}`;
    const defaultValues = this.props.workingTimeSlots;
    return (
      <div className="col-12">
        <div className={css.workingHoursTitle}>
          <h2>{t('web.listings.working_hours.default_schedule')}</h2>
          <h3>{t('web.listings.working_hours.i_am_available_on')}</h3>
        </div>
        <Form onSubmit={(submittedValues) => this.handleSubmit(submittedValues)}
          validateError={this.errorValidator} defaultValues={defaultValues}>
          { (formApi) => (
            <div>
              <form className={formClass} onSubmit={formApi.submitForm}>
                <div className="row">
                  {this.renderWeekDays(formApi)}
                </div>
                <SaveButton saveInProgress={this.props.saveInProgress}
                  saveFinished={this.props.saveFinished} />
              </form>
            </div>
          )}
        </Form>
      </div>
    );
  }
}

ListingWorkingHoursForm.propTypes = {
  workingTimeSlots: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  time_slot_options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  day_names: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  saveInProgress: PropTypes.bool,
  saveFinished: PropTypes.bool,
  actions: PropTypes.shape({
    saveChanges: PropTypes.func.isRequired,
    dataChanged: PropTypes.func.isRequired,
  }).isRequired,
  hasChanges: PropTypes.bool,
};

export default ListingWorkingHoursForm;

