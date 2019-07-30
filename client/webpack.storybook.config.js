/* eslint-env node */

const path = require('path');
const config = require('./webpack.client.base.config');

delete config.plugins;

config.module = config.module || {};
config.module.rules = config.module.rules || [];
config.module.rules.push(
  {
    test: /\.css$/,
    loaders: [
      {
        loader: 'style-loader',
        options: {
          sourceMap: true,
        },
      },
      {
        loader: 'css-loader',
        options: {
          modules: true,
          sourceMap: true,
          localIdentName: '[name]__[local]__[hash:base64:5]',
        },
      },
      {
        loader: 'postcss-loader',
      },
    ],
    include: path.resolve(__dirname, '../'),
  },
  {
    test: /\.scss$/,
    loaders: ['style-loader', 'css-loader', 'sass-loader'],
  },
  {
    test: /\.(woff2?)$/,
    loader: 'url',
    options: {
      limit: 10000,
    },
  },
  {
    test: /\.(ttf|eot)$/,
    loader: 'file',
  },
  {
    test: /\.(jpe?g|png|gif|ico)$/,
    loader: 'file-loader',
    options: {
      limit: 10000,
      name: '[name]-[hash].[ext]',
    },
  },
  {
    test: /\.svg$/,
    loader: 'raw-loader',
  }
);

// Enzyme fix: Ignore conditional require() calls which makes Enzyme compatible with old React versions.
// https://github.com/airbnb/enzyme/blob/master/docs/guides/webpack.md
config.externals = {
  jsdom: 'window',
  cheerio: 'window',
  'react/lib/ExecutionEnvironment': true,
  'react/lib/ReactContext': 'window',
  'react/addons': true,
};

config.output = {};
config.output.publicPath = '/static/';

config.devtool = 'eval-source-map';

module.exports = config;
