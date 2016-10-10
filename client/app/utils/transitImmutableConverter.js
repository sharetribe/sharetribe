import transit from 'transit-js';
import Immutable from 'immutable';
import { parse as parseImage } from '../models/ImageModel';
import { Distance, Money } from '../models/ListingModel';

// Outside of this file we should only pass UUID references, no need to export
class UUID extends Immutable.Record({ value: '' }) {
  toString() {
    return this.value;
  }
}
const toUUID = (transitUuid) => new UUID({ value: transitUuid.toString() });

const toDistance = ([value, unit]) => new Distance({ value, unit });
const toMoney = ([fractionalAmount, currency]) => new Money({ fractionalAmount, currency });

const createReader = function createReader() {
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
    handlers: {
      ':': (rep) => `:${rep}`,
      list: (rep) => Immutable.List(rep).asImmutable(),
      lstr: (rep) => Immutable.Map(rep).asImmutable(),
      u: toUUID,
      r: (rep) => rep,
      di: toDistance,
      im: parseImage,
      mn: toMoney,
    },
  });
};

const createInstance = () => {
  const reader = createReader();
  const fromJSON = (json) => reader.read(json);

  return { fromJSON };
};

export default createInstance();
