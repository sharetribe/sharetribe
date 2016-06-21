/**
 * Parse a URL search query string into an object.
 *
 * @param {String} searchQuery - query string e.g. from `window.location.search`
 *
 * @return {Object<String, String>} - parsed query string as a key/value object
 */
export const parseQuery = (searchQuery) => {
  const parts = (searchQuery || '')
          .replace(/^\?/, '')
          .replace(/#.*$/, '')
          .split('&');

  return parts.reduce((params, keyval) => {
    const pair = keyval.split('=');
    const pairLength = 2;

    if (pair.length === pairLength) {
      params[pair[0]] = decodeURIComponent(pair[1]); // eslint-disable-line no-param-reassign
    }

    return params;
  }, {});
};
