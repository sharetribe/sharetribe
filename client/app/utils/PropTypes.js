import { PropTypes } from 'react';

const { oneOfType, string, objectOf, bool, object, shape, number } = PropTypes;

const className = oneOfType([
  string,
  objectOf(bool),
]);

const routes = object.isRequired;

const marketplaceContext = shape({

  // Required props
  i18nLocale: string.isRequired,
  i18nDefaultLocale: string.isRequired,
  location: string.isRequired,
  pathname: string.isRequired,
  marketplaceId: number.isRequired,

  // Optional props
  marketplace_color1: string,
  loggedInUsername: string,
  host: string,
  href: string,
  httpAcceptLanguage: string,
  port: number,
  scheme: string,
  serverSide: bool,

}).isRequired;

export { className, routes, marketplaceContext };
