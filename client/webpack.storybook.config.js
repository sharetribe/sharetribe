/* eslint-env node */

const path = require('path');

// symlinked to .storybook/, hence the weird path
const config = require('../webpack.client.base.config');

delete config.plugins;

config.module = config.module || {};
config.module.loaders = config.module.loaders || [];
config.module.loaders.push(
  {
    test: /\.css$/,
    loaders: [
      'style-loader?sourceMap',
      'css-loader?modules&sourceMap&localIdentName=[name]__[local]__[hash:base64:5]',
      'postcss-loader',
    ],
    include: path.resolve(__dirname, '../'),
  },
  {
    test: /\.(woff2?|svg)$/,
    loader: 'url?limit=10000',
  },
  {
    test: /\.(ttf|eot)$/,
    loader: 'file',
  },
  {
    test: /\.(jpe?g|png|gif|svg|ico)$/,
    loader: 'customfile-loader?limit=10000&name=[name]-[hash].[ext]&hotMode=true',
  }
);

config.output = {};
config.output.publicPath = '/static/';

config.devtool = 'eval-source-map';

module.exports = config;
