import transit from 'transit-js';
import Immutable from 'immutable';

export const Image = Immutable.Record({
  type: ':square',
  height: 408,
  width: 408,
  url: null,
});

const ImageRefs = Immutable.Record({
  square: new Image(),
  square2x: new Image(),
});

const toImage = (rep) => {
  const knownStyles = {
    ':square': 'square',
    ':square_2x': 'square2x',
  };
  const data = rep[1];
  const images = data.map((s) => new Image({
    type: s.get(0),
    height: s.get(1),
    width: s.get(2), // eslint-disable-line no-magic-numbers
    url: s.get(3), // eslint-disable-line no-magic-numbers
  }));
  const styles = images.reduce((acc, val) => {
    const style = knownStyles[val.type];
    return style ? acc.set(style, val) : acc;
  }, new ImageRefs());
  return styles;
};

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
      r: (rep) => rep,
      im: toImage,
    },
  });
};

const createInstance = () => {
  const reader = createReader();
  const fromJSON = (json) => reader.read(json);

  return { fromJSON };
};

export default createInstance();
