import * as actionTypes from '../constants/OnboardingConstants';

export function updateGuidePage(path) {
  return {
    type: actionTypes.ONBOARDING_GUIDE_PATH_UPDATE,
    path,
  };
}
