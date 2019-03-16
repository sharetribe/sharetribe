import axios from 'axios';
import * as actionTypes from './constants';
import _ from 'lodash';
import { addFlashNotification } from '../../../actions/FlashNotificationActions';
import { t } from '../../../utils/i18n';

export const EDIT_VIEW_OPEN_HASH = 'manage-working-hours';

export const openEditView = () => ({ type: actionTypes.OPEN_EDIT_VIEW });

export const closeEditView = () => ({ type: actionTypes.CLOSE_EDIT_VIEW });

const startSaving = () => ({ type: actionTypes.START_SAVING });

const changesSaved = () => ({ type: actionTypes.CHANGES_SAVED });

const savingFailed = (e) => ({
  type: actionTypes.SAVING_FAILED,
  error: true,
  payload: e,
});

const dataLoaded = (data) => ({
  type: actionTypes.DATA_LOADED,
  payload: data,
});

export const dataChanged = () => ({ type: actionTypes.DATA_CHANGED });

const anyErrorsFromApi = (listing) => {
  const errors = listing.working_time_slots.filter((x) => _.size(x.errors) > 0);
  return errors.length > 0;
};

const csrfToken = () => {
  if (typeof document != 'undefined') {
    const metaTag = document.querySelector('meta[name=csrf-token]');

    if (metaTag) {
      return metaTag.getAttribute('content');
    }
  }

  return null;
};

export const saveChanges = (formData) =>
  (dispatch, getState) => {
    dispatch(startSaving());
    const state = getState().listingWorkingHours;
    const listingId = state.get('listing_id');
    console.log('save Listing Working Hours Changes'); // eslint-disable-line
    axios(`/int_api/listings/${listingId}/update_working_time_slots`, {
      method: 'post',
      data: formData,
      withCredentials: true,
      headers: { 'X-CSRF-Token': csrfToken() },
    }).then((response) => {
      if (anyErrorsFromApi(response.data)) {
        dispatch(addFlashNotification('error', t('web.listings.errors.availability.saving_failed')));
        dispatch(savingFailed('error'));
      } else {
        dispatch(changesSaved());
      }
      dispatch(dataLoaded(response.data));
      console.log(response); // eslint-disable-line no-console
    })
    .catch((error) => {
      dispatch(savingFailed(error));
      console.log(error); // eslint-disable-line no-console
    });

  };

