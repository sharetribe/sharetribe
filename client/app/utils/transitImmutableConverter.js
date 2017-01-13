/* eslint-disable no-magic-numbers */

import transit from 'transit-js';
import Immutable from 'immutable';
import { UUID, Distance, Money } from '../types/types';

const toUUID = (transitUuid) => new UUID({ value: transitUuid.toString() });
const toDistance = ([value, unit]) => new Distance({ value, unit });
const toMoney = ([fractionalAmount, currency]) => new Money({ fractionalAmount, currency });

/**
   See https://github.com/cognitect/transit-format
   for documentation about all Transit format types
*/
const transitFormatHandlers = {
  // Keyword
  ':': (rep) => `:${rep}`,

  // List (like a LinkedList, not Vector/Array)
  list: (rep) => Immutable.List(rep).asImmutable(),

  // UUID
  u: toUUID,

  // URI
  r: (rep) => rep,
};

/**
   List of our own common types
*/
const ownTypeHandlers = {
  // Localized string
  lstr: (rep) => Immutable.Map(rep).asImmutable(),

  // Distance
  di: toDistance,

  // Money
  mn: toMoney,
};

const ListHandler = transit.makeWriteHandler({
  tag: () => 'array',
  rep: (v) => v,
  stringRep: () => null,
});

const UUIDHandler = transit.makeWriteHandler({
  tag: () => 'u',
  rep: (v) => v.toString(),
});

const isKeyword = (str) => str.length >= 2 && str.startsWith(':');

const StringHandler = transit.makeWriteHandler({
  tag: (v) => (isKeyword(v) ? ':' : 's'),
  rep: (v) => (isKeyword(v) ? v.substring(1) : v),
});

const MapHandler = transit.makeWriteHandler({
  tag: () => 'map',
  rep: (v) => v,
  stringRep: () => null,
});

const DistanceHandler = transit.makeWriteHandler({
  tag: () => 'di',
  rep: (v) => [v.get('value'), v.get('unit')],
});

const MoneyHandler = transit.makeWriteHandler({
  tag: () => 'mn',
  rep: (v) => [v.get('fractionalAmount'), v.get('currency')],
});

export const createWriter = (handlers = []) => transit.writer('json', {
  handlers: transit.map([
    Immutable.List, ListHandler,
    Immutable.Map, MapHandler,
    UUID, UUIDHandler,
    String, StringHandler,
    Distance, DistanceHandler,
    Money, MoneyHandler,
  ].concat(handlers)),
});

export const createReader = (handlers) =>
  transit.reader('json', {
    mapBuilder: {
      init: () => Immutable.Map().asMutable(),
      add: (m, k, v) => m.set(k, v),
      finalize: (m) => m.asImmutable(),
    },
    arrayBuilder: {
      init: () => Immutable.List().asMutable(),
      add: (m, v) => m.push(v),
      finalize: (m) => m.asImmutable(),
    },
    handlers: Object.assign({}, transitFormatHandlers, ownTypeHandlers, handlers),
  });
