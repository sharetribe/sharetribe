import * as actionTypes from '../constants/ManageAvailabilityConstants';

export const allowDay = (day) => ({
  type: actionTypes.ALLOW_DAY,
  payload: day,
});

export const blockDay = (day) => ({
  type: actionTypes.BLOCK_DAY,
  payload: day,
});

export const changeMonth = (day) => ({
  type: actionTypes.CHANGE_MONTH,
  payload: day,
});

export const saveChanges = () => ({
  type: actionTypes.SAVE_CHANGES,
});

export const openEditView = () => ({
  type: actionTypes.OPEN_EDIT_VIEW,
});

export const closeEditView = () => ({
  type: actionTypes.CLOSE_EDIT_VIEW,
});
