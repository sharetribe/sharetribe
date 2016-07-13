import _ from 'lodash';

const hasCSSFilters = _.memoize(() => {
  const el = document.createElement('div');
  const filter = typeof document.body.style.webkitFilter !== 'undefined' ? 'webkitFilter' : 'filter';
  el.style[filter] = 'brightness(100%)';
  return (el.style[filter].length !== 0);
});

export { hasCSSFilters };
