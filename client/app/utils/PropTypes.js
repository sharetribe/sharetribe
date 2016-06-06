import { PropTypes } from 'react';

const { oneOfType, string, objectOf, bool, object, shape, number } = PropTypes;

const className = oneOfType([
  string,
  objectOf(bool),
]);

const routes = object.isRequired;

const railsContext = shape({
  host: string.isRequired,
  href: string.isRequired,
  httpAcceptLanguage: string.isRequired,
  i18nDefaultLocale: string.isRequired,
  i18nLocale: string.isRequired,
  location: string.isRequired,
  marketplaceId: number.isRequired,
  pathname: string.isRequired,
  port: number,
  scheme: string,
  serverSide: bool.isRequired,
}).isRequired;

export { className, routes, railsContext };
