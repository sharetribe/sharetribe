import Immutable from 'immutable';
import * as actionTypes from '../constants/ManageAvailabilityConstants';
import * as harmony from '../services/harmony';
import { expandRange } from '../utils/moment';
import { t } from '../utils/i18n';
import { addFlashNotification } from './FlashNotificationActions';

export const allowDay = (day) => ({
  type: actionTypes.ALLOW_DAY,
  payload: day,
});

export const blockDay = (day) => ({
  type: actionTypes.BLOCK_DAY,
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

export const changeMonth = (day) =>
  (dispatch, getState) => {
    dispatch(changeVisibleMonth(day));

    const state = getState().manageAvailability;

    const { start, end } = monthsToLoad(day, state.get('loadedMonths'), PRELOAD_MONTHS);

    if (start && end) {
      harmony.get('/bookables/show', {
        refId: state.get('listingUuid'),
        marketplaceId: state.get('marketplaceUuid'),
        include: ['blocks', 'bookings'].join(','),
        start: start.toJSON(),
        end: end.toJSON(),
      })
      .then((response) => {
        const groups = response.get(':included').groupBy((v) => v.get(':type'));

        const slots = Immutable.Map({
          blocks: groups.get(':block', Immutable.List()),
          bookings: groups.get(':booking', Immutable.List()),
        });

        dispatch(dataLoaded(slots, expandRange(start, end, 'months').toSet()));
      })
      .catch(() => {
        // Status looks bad, alert user
        dispatch(addFlashNotification('error', t('web.listings.errors.availability.something_went_wrong')));
      });
    }
  };

export const saveChanges = () => ({
  type: actionTypes.SAVE_CHANGES,
});

export const openEditView = () => ({
  type: actionTypes.OPEN_EDIT_VIEW,
});

export const closeEditView = () => ({
  type: actionTypes.CLOSE_EDIT_VIEW,
});
