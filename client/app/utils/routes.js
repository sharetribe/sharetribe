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
 * addDefaultArgs([1, 2, 3], {}) => [1, 2, 3, {}]
 * addDefaultArgs([1, 2, 3, {format: "json"}], {locale: "en"}) => [1, 2, 3, {format: "json", locale: "en"}]
 * addDefaultArgs([1, 2, 3, {locale: "fr"}], {locale: "en"}) => [1, 2, 3, {locale: "fr"}]
 */
const addDefaultArgs = function addDefaultArgs(args, defaultArgs) {
  const argsArray = _.toArray(args);
  const last = _.last(argsArray);

  if (last && _.isObject(last)) {
    return _.initial(argsArray).concat([_.assign({}, defaultArgs, last)]);
  } else {
    return argsArray.concat([defaultArgs]);
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

const wrapWithDefaultArgs = function wrapWithDefaultArgs(pathFns, defaultArgs) {
  return pathFns.reduce((routeObject, { pathHelperName, pathHelper }) => {
    const withDefaultArgsFn = function withDefaultArgs(...args) {
      return pathHelper(...addDefaultArgs(args, defaultArgs));
    };

    // Copy the toString function.
    // It contains the path spec, which might be useful
    // For example:
    // single_conversation_path.toString => (/:locale)/:person_id/messages/:conversation_type/:id(.:format)
    withDefaultArgsFn.toString = pathHelper.toString;

    routeObject[pathHelperName] = withDefaultArgsFn; // eslint-disable-line no-param-reassign
    return routeObject;
  }, {});
};

//
// Public API
//

/**
 * Creates a subset of all routes.
 *
 * You can pass also `defaultArgs` object, for example for "locale"
 */
const subset = function subset(routesSubset, defaultArgs = {}) {
  const pathHelpers = routesSubset.map((routeName) => {
    const pathHelperName = routeNameToPathHelperName(routeName);
    const pathHelper = Routes[pathHelperName];

    if (pathHelper) {
      return { pathHelperName, pathHelper };
    } else {
      throw new Error(_.compact([`Couldn't find named route: '${routeName}'.`, didYouMean(routeName)]).join(' '));
    }
  });

  return wrapWithDefaultArgs(pathHelpers, defaultArgs);
};

/**
 * Returns all routes.
 *
 * ** Use this ONLY in styleguide or in tests. **
 */
const all = function all(defaultArgs) {
  const pathHelperNames = _.keys(Routes).filter((key) => _.endsWith(key, '_path'));

  const pathFns = pathHelperNames.map((pathHelperName) => {
    const pathHelper = Routes[pathHelperName];
    return { pathHelperName, pathHelper };
  });

  return wrapWithDefaultArgs(pathFns, defaultArgs);
};

export { subset, all };
