import * as actionTypes from '../constants/OnboardingConstants';

export function updateGuidePage(path, pathHistoryForward) {
  return {
    type: actionTypes.ONBOARDING_GUIDE_PATH_UPDATE,
    payload: {
      path,
      pathHistoryForward,
    },
  };
}
