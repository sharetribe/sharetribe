import { paramsToQueryString } from '../utils/url';

/**
  harmony.js defines a interface for Harmony API.

  It exports two functions:

  - get(url, queryParams)
  - TODO post(url, queryParams, body)

  Internally, harmony.js sets the correct headers to the request and
  also extracts the correct CSRF token from the <meta> tag.
 */

/**
   Extracts CSRF token value from a <meta> tag.
   Returns `null` if token doesn't exist or if the environment doesn't have `document` defined.
 */
const csrfToken = () => {
  if (typeof document != 'undefined') {
    const metaTag = document.querySelector('meta[name=csrf-token]');

    if (metaTag) {
      return metaTag.getAttribute('content');
    }
  }

  return null;
};

const sendRequest = (method, url, queryParams) => {
  const harmonyApiUrl = '/harmony_proxy';

  const headers = new Headers({
    'Content-Type': 'application/json',
    Accept: 'application/json',
  });

  const csrf = csrfToken();

  if (csrf) {
    headers.append('X-CSRF-Token', csrf);
  }

  const defaultRequestOpts = {
    headers,
    credentials: 'same-origin',
  };

  const urlWithQuery = harmonyApiUrl + url + paramsToQueryString(queryParams);
  const requestOpts = Object.assign({}, defaultRequestOpts, { method });

  return window.fetch(urlWithQuery, requestOpts).then((response) => response.json());
};

const get = (url, queryParams) => sendRequest('get', url, queryParams);

export {
  get,
  // TODO implement post
};
