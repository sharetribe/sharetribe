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
function addDefaultOpts(args, defaultOpts) {
  args = _.toArray(args);
  const last = _.last(args);

  if (last && _.isObject(last)) {
    return _.initial(args).concat([_.assign({}, defaultOpts, last)]);
  } else {
    return args.concat([defaultOpts]);
  }
}

function routeNameToPathFnName(routeName) {
  return `${routeName}_path`;
}

function createSubset(fnNames, defaultOpts) {
  return fnNames.reduce(function(routeObject, fnName) {
    const pathFn = Routes[fnName];

    if (pathFn) {
      const withDefaultOptsFn = function withDefaultOpts() {
        return pathFn.apply(null, addDefaultOpts(arguments, defaultOpts));
      };

      // Copy the toString function.
      // It contains the path spec, which might be useful
      // For example:
      // single_conversation_path.toString => (/:locale)/:person_id/messages/:conversation_type/:id(.:format)
      withDefaultOptsFn.toString = pathFn.toString;

      routeObject[fnName] = withDefaultOptsFn;
      return routeObject;
    } else {
      throw new Error(`Couldn't find named route: '${fnName}'`);
    }
  }, {});
}

/**
 * Creates a subset of all routes.
 *
 * You can pass also `defaultOpts` object, for example for "locale"
 */
function subset(routesSubset, defaultOpts = {}) {
  return createSubset(routesSubset.map(pathNameToPathFnName), defaultOpts);
}

/**
 * Returns all routes. Use this ONLY in styleguide or in tests.
 */
function _all(defaultOpts) {
  const allRoutes = _.keys(Routes).filter(function(key) {
    return _.endsWith(key, '_path');
  });

  return createSubset(allRoutes, defaultOpts);
}

export { subset, _all };
