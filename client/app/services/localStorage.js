import moment from 'moment';
import Immutable from 'immutable';

const serialize = JSON.stringify;
const deserialize = JSON.parse;

const loadAvailabilityChanges = (key) => {
  try {
    const deserializedChanges = deserialize(localStorage.getItem(key));

    // restore day string as moment
    return Immutable.fromJS(deserializedChanges.map((c) =>
      ({ ...c, day: moment(c.day) })
    ));
  } catch (err) {
    return new Immutable.List();
  }
};

const saveAvailabilityChanges = (key, state) => {
  try {
    localStorage.setItem(key, serialize(state));
  } catch (err) {
    console.warn('Unable to persist state to localStorage:', err); // eslint-disable-line no-console
  }
};

export {
  loadAvailabilityChanges,
  saveAvailabilityChanges,
};
