import transit from 'transit-js';
import Immutable from 'immutable';
import { UUID, Distance, Money } from '../types/types';

const toUUID = (transitUuid) => new UUID({ value: transitUuid.toString() });
const toDistance = ([value, unit]) => new Distance({ value, unit });
const toMoney = ([fractionalAmount, currency]) => new Money({ fractionalAmount, currency });

const defaultHandlers = {
  ':': (rep) => `:${rep}`,
  list: (rep) => Immutable.List(rep).asImmutable(),
  lstr: (rep) => Immutable.Map(rep).asImmutable(),
  u: toUUID,
  r: (rep) => rep,
  di: toDistance,
  mn: toMoney,
};

const createReader = function createReader(handlers) {
  return transit.reader('json', {
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
    handlers: Object.assign({}, defaultHandlers, handlers),
  });
};

export const createInstance = (handlers = {}) => {
  const reader = createReader(handlers);
  const fromJSON = (json) => {
    return reader.read(json);
  };

  return { fromJSON };
};
