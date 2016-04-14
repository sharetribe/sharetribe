import * as actionTypes from '../constants/OnboardingConstants';

const initialState = {
  lastActionType: null,
  path: '',
};

export default function onboardingGuideReducer(state = initialState, action) {
  const { type, path } = action;
  switch (type) {
    case actionTypes.ONBOARDING_GUIDE_PATH_UPDATE:
      return Object.assign({}, state, {
        lastActionType: type,
        path
      });
    default:
      return state;
  }
}
