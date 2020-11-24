import * as actionTypes from '../constants/OnboardingConstants';

const initialState = {
  lastActionType: null,
  payload: {
    path: null,
    page: null,
    pathHistoryForward: true,
  },
};

export default function onboardingGuideReducer(state = initialState, action) {
  const { type, payload } = action;
  switch (type) {
    case actionTypes.ONBOARDING_GUIDE_PATH_UPDATE:
      return Object.assign({}, state, {
        lastActionType: type,
        path: payload.path,
        page: payload.page,
        pathHistoryForward: payload.pathHistoryForward,
      });
    default:
      return state;
  }
}
