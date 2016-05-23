import { PropTypes } from 'react';

const className = PropTypes.oneOfType([
  PropTypes.string,
  PropTypes.objectOf(PropTypes.bool),
]);

export { className };
