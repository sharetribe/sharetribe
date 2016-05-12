/* eslint-env node */

const path = require('path');

const config = {
  module: {
    loaders: [
      {
        test: /\.css$/,
        loaders: [
          'style',
          'css',
          'postcss',
        ],
        include: path.resolve(__dirname, '../'),
      },
      {
        test: /\.scss$/,
        loader:
          'style' +
          '!css?modules' +
          '!postcss' +
          '!sass' +
          '!sass-resources',
        include: path.resolve(__dirname, '../'),
      },
      { test: /\.(jpe?g|png|gif|svg|ico)$/, loader: 'url?limit=10000' },
    ],
  },
  sassResources: ['./app/assets/styles/app-variables.scss'],
};

console.log('Webpack dev build for Rails'); // eslint-disable-line no-console
config.devtool = 'eval-source-map';

module.exports = config;
