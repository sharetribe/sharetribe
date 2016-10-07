import Immutable from 'immutable';

export const Image = Immutable.Record({
  type: null,
  height: null,
  width: null,
  url: null,
});

export const ImageRefs = Immutable.Record({
  square: null,
  square2x: null,
  medium: null,
  small: null,
  thumb: null,
});

export const parse = (data) => {
  const knownStyles = {
    ':square': 'square',
    ':square_2x': 'square2x',
    ':medium': 'medium',
    ':small': 'small',
    ':thumb': 'thumb',
  };
  const images = data.map(([type, height, width, url]) =>
    new Image({ type, height, width, url }));
  const styles = images.reduce((acc, val) => {
    const style = knownStyles[val.type];
    return style ? acc.set(style, val) : acc;
  }, new ImageRefs());
  return styles;
};
