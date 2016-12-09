import _ from 'lodash';

const paramsToQueryString = (paramsMap) => {
  if (_.isEmpty(paramsMap)) {
    return '';
  } else {
    const keyValues = _.map(paramsMap, (val, key) => [
      window.encodeURIComponent(key),
      window.encodeURIComponent(val),
    ].join('=')).join('&');
    return `?${keyValues}`;
  }
};

/**
 * Parse a URL search query string.
 *
 * @param {String} location - location URL e.g. from `window.location`
 *
 * @return {String} - parsed query string
 */
const parseQueryString = (location) => {
  const parts = location.split('?');
  if (parts.length > 1) {
    return parts[1].split('#')[0];
  } else {
    return '';
  }
};

/**
 * Parse a URL search query string into an object.
 *
 * @param {String} searchQuery - query string e.g. from `window.location.search`
 *
 * @return {Object<String, String>} - parsed query string as a key/value object
 */
const parseQuery = (searchQuery) => {
  const parts = (searchQuery || '')
          .replace(/^\?/, '')
          .replace(/#.*$/, '')
          .split('&');

  return parts.reduce((params, keyval) => {
    const pair = keyval.split('=');
    const pairLength = 2;

    if (pair.length === pairLength) {
      // We also have to deal with + char encoding a space since Rails
      // likes these more and decodeURIComponent doesn't decode them.
      params[pair[0]] = decodeURIComponent(pair[1].replace(/\+/g, ' ')); // eslint-disable-line no-param-reassign
    }

    return params;
  }, {});
};

/**
 * Parse search params from a URL.
 *
 * @param {String} location - location URL e.g. from `window.location`
 * @param {Array} restrict_to_params - fetch only specified params
 *
 * @return {Object<String, String>} - parsed params from query string
 */
const parseSearchQueryParams = function parseSearchQueryParams(location, restrict_to_params) {
  const searchQuery = parseQueryString(location);
  const parsedParams = parseQuery(searchQuery);
  return Object.keys(parsedParams).reduce((params, key) => {
    if (restrict_to_params == null || restrict_to_params.indexOf(key) !== -1) {
      params[key] = parsedParams[key]; // eslint-disable-line no-param-reassign
    }
    return params;
  }, {});
};

/**
 * Curry function to return function with cherry-picked params
 *
 * @param {String} location - location URL e.g. from `window.location`
 *
 * @return {Function} - function that takes location as parameter and fetches only values for specified keys
 */
const currySearchParams = function currySearchParams(restrict_to_params) {
  return function curryWrap(location) {
    return parseSearchQueryParams(location, restrict_to_params);
  };
};

const upsertSearchQueryParam = function upsertSearchQueryParam(location, param, value) {
  const originalParams = parseSearchQueryParams(location);
  const newParams = { ...originalParams, [param]: value };
  return _.map(newParams, (v, k) =>
    `${encodeURIComponent(k)}=${encodeURIComponent(v)}`
  ).join('&');
};

export {
  parseQuery,
  parseQueryString,
  parseSearchQueryParams,
  currySearchParams,
  upsertSearchQueryParam,
  paramsToQueryString,
};
