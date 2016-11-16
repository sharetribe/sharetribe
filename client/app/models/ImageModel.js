import Immutable from 'immutable';

export const Image = Immutable.Record({
  type: null,
  height: null,
  width: null,
  url: null,
});

const ImageRefs = Immutable.Record({
  square: null,
  square2x: null,
  medium: null,
  small: null,
  thumb: null,
  original: null,
});

export const ListingImage = Immutable.Record({
  square: new Image(),
  square2x: new Image(),
});

export const AvatarImage = Immutable.Record({
  thumb: new Image(),
  small: new Image(),
  medium: new Image(),
  original: new Image(),
});

export const parse = (data) => {
  const knownStyles = {
    ':square': 'square',
    ':square_2x': 'square2x',
    ':medium': 'medium',
    ':small': 'small',
    ':thumb': 'thumb',
    ':original': 'original',
  };

  // Array destructuring would be better, but ES6 Symbol is needed in that case
  const images = data.map((i) =>
    new Image({ type: i.get(0), height: i.get(1), width: i.get(2), url: i.get(3) }) // eslint-disable-line no-magic-numbers
  );
  const styles = images.reduce((acc, val) => {
    const style = knownStyles[val.type];
    return style ? acc.set(style, val) : acc;
  }, new ImageRefs());
  return styles;
};
