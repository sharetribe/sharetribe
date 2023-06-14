import * as actionTypes from '../constants/ManageAvailabilityConstants';
import { t } from '../utils/i18n';
import { expandRange } from '../utils/moment';
import { addFlashNotification } from './FlashNotificationActions';
import { hasChanges } from '../reducers/ManageAvailabilityReducer';
import axios from 'axios';
import moment from 'moment';

// Delay to show the save button checkmark before closing the winder.
const SAVE_FINISHED_DELAY = 2000;

export const EDIT_VIEW_OPEN_HASH = 'manage-availability';

export const openEditView = () => ({ type: actionTypes.OPEN_EDIT_VIEW });

export const closeEditView = () => ({ type: actionTypes.CLOSE_EDIT_VIEW });

export const blockDay = (day) => ({
  type: actionTypes.BLOCK_DAY,
  payload: day,
});

export const unblockDay = (day) => ({
  type: actionTypes.UNBLOCK_DAY,
  payload: day,
});

const changeVisibleMonth = (day) => ({
  type: actionTypes.CHANGE_MONTH,
  payload: day,
});

export const dataLoaded = (slots, loadedMonths) => ({
  type: actionTypes.DATA_LOADED,
  payload: slots.merge({ loadedMonths }),
});

export const dataBlockedDatesLoaded = (data, loadedMonths) => ({
  type: actionTypes.DATA_BLOCKED_DATES_LOADED,
  payload: { blocked_dates: data, loadedMonths: loadedMonths },
});

export const dataBookedDatesLoaded = (data) => ({
  type: actionTypes.DATA_BOOKED_DATES_LOADED,
  payload: data,
});


/**
   Number of extra months to preload.
   0 mean no preloading.
 */
const PRELOAD_MONTHS = 2;

/**
   Given a `date` and number of months to preload, return a List of
   moment dates representing the start of the month that should be
   loaded.

   @param {moment} date - Date representing the month
   @params {number} preloadMonths - Number of months to preload
   @return {List[moment]} List of months that should be loaded
 */
const loadRange = (date, preloadMonths) => {
  const startOfMonth = date.clone().startOf('month');
  const endOfMonthExclusive = startOfMonth.clone().add(1, 'month');

  const start = startOfMonth.clone().subtract(preloadMonths, 'months');
  const end = endOfMonthExclusive.clone().add(preloadMonths, 'months');

  return expandRange(start, end, 'months');
};

/**
   Given a list of `months` and a Set of already `loadedMonths`,
   return an object { start, end } where months that are already
   loaded are removed from the beginning and the end of the range.

   Example:

   start: 4
   end: 11
   loadedMonths: [2, 3, 4, 5, 6, 9, 11, 12]

   result: { start: 7, end: 10 }

 */
const removeLoadedMonths = (months, loadedMonths) => ({
  start: months.find((s) => !loadedMonths.includes(s)),
  end: months.findLast((e) => !loadedMonths.includes(e)),
});

const monthsToLoad = (day, loadedMonths, preloadMonths) =>
  removeLoadedMonths(loadRange(day, preloadMonths), loadedMonths);

const getBlockedDates = (listingId, start, end) => (
  axios(
    `/int_api/listings/${listingId}/blocked_dates`,
    {
      method: 'get',
      params: {
        start_on: start.format('YYYY-MM-DD'),
        end_on: end.format('YYYY-MM-DD'),
      },
    })
);

const getBookedDates = (listingId, start, end) => (
  axios(
    `/int_api/listings/${listingId}/bookings`,
    {
      method: 'get',
      params: {
        start_on: start.format('YYYY-MM-DD'),
        end_on: end.format('YYYY-MM-DD'),
      },
    })
);

export const changeMonth = (day) =>
  (dispatch, getState) => {
    dispatch(changeVisibleMonth(day));

    const state = getState().manageAvailability;

    const { start, end } = monthsToLoad(day, state.get('loadedMonths'), PRELOAD_MONTHS);

    if (start && end) {
      getBlockedDates(state.get('listingId'), start, end)
      .then((response) => {
        const blocked_dates = response.data.map((x) => ({ id: x.id, blocked_at: moment.utc(x.blocked_at) }));
        dispatch(dataBlockedDatesLoaded(blocked_dates, expandRange(start, end, 'months').toSet()));
      })
      .catch(() => {
        // Status looks bad, alert user
        dispatch(addFlashNotification('error', t('web.listings.errors.availability.something_went_wrong')));
      });
      getBookedDates(state.get('listingId'), start, end)
      .then((response) => {
        const booked_dates = response.data.map((x) => (moment.utc(x)));
        dispatch(dataBookedDatesLoaded(booked_dates));
      })
      .catch(() => {
        // Status looks bad, alert user
        dispatch(addFlashNotification('error', t('web.listings.errors.availability.something_went_wrong')));
      });
    }
  };

export const startSaving = () => ({
  type: actionTypes.START_SAVING,
});

export const changesSaved = () => ({
  type: actionTypes.CHANGES_SAVED,
});

export const savingFailed = (e) => ({
  type: actionTypes.SAVING_FAILED,
  error: true,
  payload: e,
});

const timeout = (ms) => new Promise((resolve) => {
  window.setTimeout(resolve, ms);
});

const csrfToken = () => {
  if (typeof document != 'undefined') {
    const metaTag = document.querySelector('meta[name=csrf-token]');

    if (metaTag) {
      return metaTag.getAttribute('content');
    }
  }

  return null;
};

const convertToApi = (state) => {
  const result = [];
  const blocked_dates = state.get('blocked_dates');
  blocked_dates.forEach((blocked_date) => {
    result.push({
      id: blocked_date.id,
      blocked_at: blocked_date.blocked_at.format('YYYY-MM-DD'),
      _destroy: blocked_date.destroy });
  });
  return { listing: { blocked_dates_attributes: result } };
};

const updateBlockedDates = (listingId, data) => {
  axios(
    `/int_api/listings/${listingId}/update_blocked_dates`,
    {
      method: 'post',
      data: data,
      withCredentials: true,
      headers: { 'X-CSRF-Token': csrfToken() },
    });
};

export const saveChanges = () =>
  (dispatch, getState) => {
    dispatch(startSaving());

    const state = getState().manageAvailability;
    const listingId = state.get('listingId');
    const requests = [];

    if (hasChanges(state)) {
      requests.push(updateBlockedDates(listingId, convertToApi(state)));
    }

    if (requests.length === 0) {
      throw new Error('No changes to save.');
    }

    Promise.all(requests)
      .then(() => {
        dispatch(changesSaved());

        // Wait a bit to show the save button in the done state before
        // closing the winder.
        return timeout(SAVE_FINISHED_DELAY);
      })
      .then(() => {
        dispatch(closeEditView());
      })
      .catch((e) => {
        dispatch(addFlashNotification('error', t('web.listings.errors.availability.saving_failed')));
        dispatch(savingFailed(e));
      });
  };

