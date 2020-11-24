const path = require('path');
const cssnext = require('postcss-cssnext');
const mixins = require('postcss-mixins');
const customProperties = require('postcss-custom-properties');
const cssVariables = require('./app/assets/styles/variables');
const customMedia = require('postcss-custom-media');
const mediaQueries = require('./app/assets/styles/media-queries');

module.exports = {
  plugins: [
    mixins({ mixinsFiles: path.join(__dirname, 'app/assets/styles/mixins.css') }),
    customMedia({ extensions: mediaQueries }),
    customProperties({ variables: cssVariables }),
    cssnext({ browsers: ['last 2 versions', 'not ie < 11', 'not ie_mob < 11', 'ie >= 11', 'iOS >= 8'] }),
  ],
};

