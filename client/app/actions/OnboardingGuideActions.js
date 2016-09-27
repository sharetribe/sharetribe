import * as actionTypes from '../constants/OnboardingConstants';

const updateGuidePage = function updateGuidePage(page, path, pathHistoryForward) {
  return {
    type: actionTypes.ONBOARDING_GUIDE_PATH_UPDATE,
    payload: {
      path,
      page,
      pathHistoryForward,
    },
  };
};

export { updateGuidePage };
