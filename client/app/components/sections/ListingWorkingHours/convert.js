let firstDayOfWeek = 0;
let weekBaseDays = [];

export const setFirstDayOfWeek = (dayNumber) => {
  firstDayOfWeek = dayNumber;
  const monSat = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat'];
  const sun = ['sun'];
  if (firstDayOfWeek === 0) {
    weekBaseDays = monSat.concat(sun);
  } else {
    weekBaseDays = sun.concat(monSat);
  }
};

export const weekDays = () => (weekBaseDays);

export const convertFromApi = (listing) => {
  const days = [];
  weekDays().forEach((day) => {
    const slots = listing.working_time_slots.filter((x) => x.week_day === day);
    days.push({
      working_time_slots: slots,
      enabled: slots.length > 0,
    });
  });
  return { days: days }; // eslint-disable-line babel/object-shorthand
};

export const convertToApi = (formData) => {
  let slots = [];
  formData.days.forEach((dayData) => {
    if (!dayData.enabled) {
      dayData.working_time_slots.forEach((timeSlot) => {
        timeSlot._destroy = '1';  // eslint-disable-line no-underscore-dangle, no-param-reassign
      });
    }
    slots = slots.concat(dayData.working_time_slots);
  });
  return { listing: { working_time_slots_attributes: slots } };
};

