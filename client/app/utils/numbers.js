const MINIMUM_DISTANCE = 0.1;
const PRECISION = 2;

const sigFigs = function sigFigs(n, sig) {
  return parseFloat(n.toPrecision(sig));
};

const formatDistance = function formatDistance(distance, unit, precision = PRECISION, minimumDistance = MINIMUM_DISTANCE) {
  if (distance == null) {
    return null;
  }

  const precisionWithCloseBy = (distance < 1) ? 1 : precision;
  return (distance < minimumDistance) ?
    `< 0.1 ${unit}` :
    `${sigFigs(distance, precisionWithCloseBy)} ${unit}`;
};

const formatPrice = (price, unit) => `${unit} ${price}`;

export { formatDistance, formatPrice };
