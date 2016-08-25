import _ from 'lodash';

const hasCSSFilters = _.memoize(() => {
  const el = document.createElement('div');
  const filter = typeof document.body.style.webkitFilter !== 'undefined' ? 'webkitFilter' : 'filter';
  el.style[filter] = 'brightness(100%)';
  return (el.style[filter].length !== 0);
});


// React has an internal variable 'canUseDOM', which we emulate here.
const canUseDOM = !!(typeof window !== 'undefined' &&
                    window.document &&
                    window.document.createElement);

const canUsePushState = !!(typeof history !== 'undefined' &&
                            history.pushState);

const hasTouchEvents = !!(typeof window !== 'undefined' &&
                          (('ontouchstart' in window) ||
                            window.navigator.msMaxTouchPoints > 0));

export {
  canUseDOM,
  canUsePushState,
  hasCSSFilters,
  hasTouchEvents,
};
