import React, { Component, PropTypes } from 'react';
import serialize from 'form-serialize';
import { t } from '../../../utils/i18n';

import css from './form.css';
import loadingImage from './images/loading.svg';
import checkmarkImage from './images/checkmark.svg';

class TimeSlot extends Component {
  constructor(props) {
    super(props);
    this.state = {
      remove: false,
    };
    this.handleRemove = this.handleRemove.bind(this);
  }

  handleRemove(event) {
    event.preventDefault();
    this.props.onChange();
    this.setState({ remove: true }); // eslint-disable-line react/no-set-state
  }

  render() {
    const timeSlot = this.props.timeSlot;
    const index = this.props.index;
    const timeSlotId = timeSlot.id || '';
    const timeOptions = this.props.time_slot_options.map((option, optionIndex) =>
      <option key={optionIndex} value={option.value}>{option.name}</option>
    );
    return (
      <div>
        <div className={`timeSlot ${this.state.remove || this.context.remove ? 'hidden' : ''}`}>
          <span className="starTime">{t('web.listings.working_hours.start_time')}</span>
          <select defaultValue={timeSlot.from} name={`listing[working_time_slots_attributes][${index}][from]`} onChange={this.props.onChange}>
            {timeOptions}
          </select>
          <span className="endTime">{t('web.listings.working_hours.end_time')}</span>
          <select defaultValue={timeSlot.till} name={`listing[working_time_slots_attributes][${index}][till]`} onChange={this.props.onChange}>
            {timeOptions}
          </select>
          <input type="hidden" name={`listing[working_time_slots_attributes][${index}][week_day]`}
            defaultValue={timeSlot.week_day} />
          <a className="remove" onClick={this.handleRemove}>
            <i className="icon-minus icon-part" />
          </a>
        </div>
        <input type="hidden" name={`listing[working_time_slots_attributes][${index}][id]`}
          defaultValue={timeSlotId} />
        <input type="hidden" name={`listing[working_time_slots_attributes][${index}][_destroy]`}
          defaultValue='1' disabled={!(this.state.remove || this.context.remove)} />
      </div>
    );
  }
}
TimeSlot.propTypes = {
  timeSlot: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  index: PropTypes.number.isRequired,
  time_slot_options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  onChange: PropTypes.func.isRequired,
};
TimeSlot.contextTypes = {
  remove: PropTypes.bool,
};

class Day extends Component {
  constructor(props) {
    super(props);
    this.state = {
      timeSlots: props.timeSlots,
      enabled: props.timeSlots.length > 0,
    };
    this.handleAddMore = this.handleAddMore.bind(this);
    this.handleEnabled = this.handleEnabled.bind(this);
  }

  getChildContext() {
    return { remove: !this.state.enabled };
  }

  componentWillReceiveProps(nextProps) {
    this.setState({ // eslint-disable-line react/no-set-state
      timeSlots: nextProps.timeSlots,
    });
  }

  newTimeSlot() {
    return {
      week_day: this.props.day,
      from: '09:00',
      till: '17:00',
    };
  }

  handleAddMore(event) {
    event.preventDefault();
    this.props.addMore(this.newTimeSlot());
  }

  handleEnabled() {
    this.props.onChange();
    this.setState((prevState) => ({ // eslint-disable-line react/no-set-state
      enabled: !prevState.enabled,
    }));
  }

  render() {
    const TIME_SLOTS_PER_DAY = 100;
    const startIndex = this.props.index * TIME_SLOTS_PER_DAY;
    const remove = !this.state.enabled;
    const options = this.props.time_slot_options;
    const timeSlots = this.state.timeSlots.map((timeSlot, index) => {
      const timeSlotIndex = startIndex + index;
      return <TimeSlot timeSlot={timeSlot} index={timeSlotIndex} remove={remove}
        time_slot_options={options} key={timeSlotIndex} onChange={this.props.onChange} />;
    });

    return (
      <div className={css.weekDay}>
        <label className="title">
          <input type="checkbox" defaultValue='1' checked={this.state.enabled} onChange={this.handleEnabled} />
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
Day.propTypes = {
  timeSlots: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  day: PropTypes.string.isRequired,
  dayName: PropTypes.string.isRequired,
  index: PropTypes.number.isRequired,
  time_slot_options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  onChange: PropTypes.func.isRequired,
  addMore: PropTypes.func.isRequired,
};
Day.childContextTypes = {
  remove: PropTypes.bool,
};

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

    return (
      <button className={css.saveButton} disabled={this.props.saveInProgress || this.props.saveFinished}
        dangerouslySetInnerHTML={html} /> // eslint-disable-line react/no-danger
    );
  }
}
SaveButton.propTypes = {
  saveInProgress: PropTypes.bool.isRequired,
  saveFinished: PropTypes.bool.isRequired,
};

class ListingWorkingHoursForm extends Component {
  static days = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat'];

  constructor(props) {
    super(props);
    this.state = {
      timeSlots: props.listing.working_time_slots,
    };
    this.handleSubmit = this.handleSubmit.bind(this);
    this.handleChanges = this.handleChanges.bind(this);
    this.addMore = this.addMore.bind(this);
  }

  componentWillReceiveProps(nextProps) {
    this.setState({ // eslint-disable-line react/no-set-state
      timeSlots: nextProps.listing.working_time_slots,
    });
  }

  handleChanges() {
    this.props.actions.dataChanged();
  }

  addMore(timeSlot) {
    this.handleChanges();
    this.setState((prevState) => { // eslint-disable-line react/no-set-state
      prevState.timeSlots.push(timeSlot);
      return { timeSlots: prevState.timeSlots };
    });
  }

  renderWeekDays() {
    return ListingWorkingHoursForm.days.map((day, index) => {
      const timeSlots = this.state.timeSlots.filter((x) => x.week_day === day);
      const dayName = this.props.day_names[index];
      return (
        <div className="row" key={index}>
          <Day timeSlots={timeSlots} day={day} dayName={dayName} onChange={this.handleChanges}
            time_slot_options={this.props.time_slot_options} index={index} addMore={this.addMore} />
        </div>
      );
    });
  }

  handleSubmit(event) {
    event.preventDefault();
    const formData = serialize(event.target, { hash: true });
    this.props.actions.saveChanges(formData);
  }

  render() {
    return (
      <div className="col-12">
        <div className={css.workingHoursTitle}>
          <h2>{t('web.listings.working_hours.default_schedule')}</h2>
          <h3>{t('web.listings.working_hours.i_am_available_on')}</h3>
        </div>
        <form onSubmit={this.handleSubmit}>
          <div className="row">
            {this.renderWeekDays()}
          </div>
          <SaveButton saveInProgress={this.props.saveInProgress}
            saveFinished={this.props.saveFinished} />
        </form>
      </div>
    );
  }
}
ListingWorkingHoursForm.propTypes = {
  listing: PropTypes.object.isRequired, // eslint-disable-line react/forbid-prop-types
  time_slot_options: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  day_names: PropTypes.array.isRequired, // eslint-disable-line react/forbid-prop-types
  saveInProgress: PropTypes.bool,
  saveFinished: PropTypes.bool,
  actions: PropTypes.shape({
    saveChanges: PropTypes.func.isRequired,
    dataChanged: PropTypes.func.isRequired,
  }).isRequired,
};

export default ListingWorkingHoursForm;

