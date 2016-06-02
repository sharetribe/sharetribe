/* eslint-env commonjs */

import _ from 'lodash';

let Routes = {};

try {
  Routes = require('../routes/routes.js');
} catch (e) {
  console.warn('Can not load route bundle routes.js'); // eslint-disable-line no-console
}

/**
 * Examples:
 *
 * addDefaultOpts([1, 2, 3], {}) => [1, 2, 3, {}]
 * addDefaultOpts([1, 2, 3, {format: "json"}], {locale: "en"}) => [1, 2, 3, {format: "json", locale: "en"}]
 * addDefaultOpts([1, 2, 3, {locale: "fr"}], {locale: "en"}) => [1, 2, 3, {locale: "fr"}]
 */
const addDefaultOpts = function addDefaultOpts(args, defaultOpts) {
  const argsArray = _.toArray(args);
  const last = _.last(argsArray);

  if (last && _.isObject(last)) {
    return _.initial(argsArray).concat([_.assign({}, defaultOpts, last)]);
  } else {
    return argsArray.concat([defaultOpts]);
  }
};

const didYouMean = function didYouMean(routeName) {
  if (_.endsWith(routeName, '_path') && Routes[routeName]) {
    return `Did you mean '${routeName.replace(/_path$/, '')}'?`;
  } else {
    return null;
  }
};

const routeNameToPathHelperName = function routeNameToPathHelperName(routeName) {
  return `${routeName}_path`;
};

const wrapWithDefaultOpts = function wrapWithDefaultOpts(pathFns, defaultOpts) {
  return pathFns.reduce((routeObject, { pathHelperName, pathHelper }) => {
    const withDefaultOptsFn = function withDefaultOpts(...args) {
      return pathHelper(...addDefaultOpts(args, defaultOpts));
    };

    // Copy the toString function.
    // It contains the path spec, which might be useful
    // For example:
    // single_conversation_path.toString => (/:locale)/:person_id/messages/:conversation_type/:id(.:format)
    withDefaultOptsFn.toString = pathHelper.toString;

    routeObject[pathHelperName] = withDefaultOptsFn; // eslint-disable-line no-param-reassign
    return routeObject;
  }, {});
};

//
// Public API
//

/**
 * Creates a subset of all routes.
 *
 * You can pass also `defaultOpts` object, for example for "locale"
 */
const subset = function subset(routesSubset, defaultOpts = {}) {
  const pathHelpers = routesSubset.map((routeName) => {
    const pathHelperName = routeNameToPathHelperName(routeName);
    const pathHelper = Routes[pathHelperName];

    if (pathHelper) {
      return { pathHelperName, pathHelper };
    } else {
      throw new Error(_.compact([`Couldn't find named route: '${routeName}'.`, didYouMean(routeName)]).join(' '));
    }
  });

  return wrapWithDefaultOpts(pathHelpers, defaultOpts);
};

/**
 * Returns all routes. Use this ONLY in styleguide or in tests.
 */
const all = function all(defaultOpts) {
  const pathHelperNames = _.keys(Routes).filter((key) => _.endsWith(key, '_path'));

  const pathFns = pathHelperNames.map((pathHelperName) => {
    const pathHelper = Routes[pathHelperName];
    return { pathHelperName, pathHelper };
  });

  return wrapWithDefaultOpts(pathFns, defaultOpts);
};

export { subset, all };
