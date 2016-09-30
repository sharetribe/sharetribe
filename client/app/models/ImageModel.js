import Immutable from 'immutable';

export const Image = Immutable.Record({
  type: ':square',
  height: 408,
  width: 408,
  url: null,
});

export const ImageRefs = Immutable.Record({
  square: new Image(),
  square2x: new Image(),
});

export const parse = (data) => {
  const knownStyles = {
    ':square': 'square',
    ':square_2x': 'square2x',
  };
  const images = data.map(([type, height, width, url]) =>
    new Image({ type, height, width, url }));
  const styles = images.reduce((acc, val) => {
    const style = knownStyles[val.type];
    return style ? acc.set(style, val) : acc;
  }, new ImageRefs());
  return styles;
};
