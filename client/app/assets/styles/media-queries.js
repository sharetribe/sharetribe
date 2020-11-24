/* eslint-env node */
const variables = require('./variables');

const medium = variables['--breakpointMedium'];
const mediumUpperLimit = variables['--breakpointLarge'];
const largeLowerlimit = variables['--breakpointLarge'] + 1;
const wideSearch = variables['--breakpointSearchWide'];

module.exports = {

  // Variable expansion from the generated media queries doesn't work,
  // so we must add those manually to the output.
  '--medium-viewport': `(min-width: ${medium}px)`,
  '--large-viewport': `(min-width: ${largeLowerlimit}px)`,
  '--small-and-medium-viewport': `(max-width: ${mediumUpperLimit}px)`,

  '--search-desktop-wide': `(min-width: ${wideSearch}px)`,
};
