/**
   This file contains common types (i.e. defined Immutable Records).

   All types are currently in this one file, but in the future if
   the number of types grow, we can split the type to smaller chunks.
 */

import Immutable from 'immutable';

export class UUID extends Immutable.Record({ value: '' }) {
  toString() {
    return this.value;
  }
}

export const Distance = Immutable.Record({
  value: 0,
  unit: 'km',
});

export const Money = Immutable.Record({
  fractionalAmount: 0,
  currency: 'USD',
});
