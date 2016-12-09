import { paramsToQueryString } from '../utils/url';

/**
  harmony.js defines a interface for Harmony API.

  It exports two functions:

  - get(url, queryParams)
  - TODO post(url, queryParams, body)

  Internally, harmony.js sets the correct headers to the request and
  also extracts the correct CSFR token from the <meta> tag.
*/

const extractCsfrToken = () =>
  document.querySelector('meta[name=csrf-token]').getAttribute('content');

const constructRequestSender = (csfrToken) => {
  const harmonyApiUrl = '/harmony_proxy';

  const headers = new Headers({
    'X-CSRF-Token': csfrToken,
    'Content-Type': 'application/json',
    Accept: 'application/json',
  });

  const defaultRequestOpts = {
    headers,
    credentials: 'same-origin',
  };

  return (method, url, queryParams) => {
    const urlWithQuery = harmonyApiUrl + url + paramsToQueryString(queryParams);
    const requestOpts = Object.assign({}, defaultRequestOpts, { method });

    return window.fetch(urlWithQuery, requestOpts).then((response) => response.json());
  };
};

const sendRequest = constructRequestSender(extractCsfrToken());

const get = (url, queryParams) => sendRequest('get', url, queryParams);

export {
  get,
  // TODO implement post
};
