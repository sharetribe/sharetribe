import * as actionTypes from '../constants/OnboardingConstants';

export function updateGuidePage(page, path, pathHistoryForward) {
  return {
    type: actionTypes.ONBOARDING_GUIDE_PATH_UPDATE,
    payload: {
      path,
      page,
      pathHistoryForward,
    },
  };
}
