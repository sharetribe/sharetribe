/* eslint-env node */

const path = require('path');

// symlinked to .storybook/, hence the weird path
const config = require('../webpack.client.base.config');

delete config.plugins;

config.module.loaders.push(
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
  { test: /\.(jpe?g|png|gif|svg|ico)$/, loader: 'url?limit=10000' }
);

config.devtool = 'eval-source-map';

module.exports = config;
