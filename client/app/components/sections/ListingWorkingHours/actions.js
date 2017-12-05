import axios from 'axios';
import * as actionTypes from './constants';

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
      dispatch(changesSaved());
      dispatch(dataLoaded(response.data));
      console.log(response); // eslint-disable-line no-console
    })
    .catch((error) => {
      savingFailed(error);
      console.log(error); // eslint-disable-line no-console
    });

  };

