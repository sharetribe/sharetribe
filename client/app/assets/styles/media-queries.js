/* eslint-env node */
const variables = require('./variables');

const medium = variables['--breakpointMedium'];
const large = variables['--breakpointLarge'];

module.exports = {

  // Variable expansion from the generated media queries doesn't work,
  // so we must add those manually to the output.
  '--medium-viewport': `(min-width: ${medium})`,
  '--large-viewport': `(min-width: ${large})`,
};
