/* eslint-env node */

const path = require('path');

// symlinked to .storybook/, hence the weird path
const config = require('../webpack.client.base.config');

delete config.plugins;

config.module.loaders.push(
  {
    test: /\.css$/,
    loaders: [
      'style-loader?sourceMap',
      'css-loader?modules&sourceMap&localIdentName=[name]__[local]__[hash:base64:5]',
      'postcss-loader',
    ],
    include: path.resolve(__dirname, '../'),
  }
);
config.output = {};
config.output.publicPath =  '/static/';

config.devtool = 'eval-source-map';

module.exports = config;
