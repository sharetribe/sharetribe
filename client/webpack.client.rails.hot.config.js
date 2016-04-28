const Promise = require('es6-promise');
Promise.polyfill();

const path = require('path');
const webpack = require('webpack');
const config = require('./webpack.client.base.config');
const hotRailsPort = process.env.HOT_RAILS_PORT || 3500;

config.entry.app.push(
  `webpack-dev-server/client?http://lvh.me:${hotRailsPort}`,
  'webpack/hot/only-dev-server'
);

config.output = {
  filename: '[name]-bundle.js',
  path: path.join(__dirname, 'public'),
  publicPath: `http://lvh.me:${hotRailsPort}/`,
};

config.module.loaders.push(
  {
    test: /\.jsx?$/,
    loader: 'babel',
    exclude: /node_modules/,
    query: {
      plugins: [
        [
          'react-transform',
          {
            transforms: [
              {
                transform: 'react-transform-hmr',
                imports: ['react'],
                locals: ['module'],
              },
            ],
          },
        ],
      ],
    },
  },
  {
    test: /\.css$/,
    loaders: [
      'style',
      'css?modules&importLoaders=1&localIdentName=[name]__[local]__[hash:base64:5]',
      'postcss',
    ],
  },
  {
    test: /\.scss$/,
    loaders: [
      'style',
      'css?modules&importLoaders=3&localIdentName=[name]__[local]__[hash:base64:5]',
      'postcss',
      'sass',
      'sass-resources',
    ],
  }
);

config.plugins.push(
  new webpack.HotModuleReplacementPlugin(),
  new webpack.NoErrorsPlugin()
);

config.devtool = 'eval-source-map';

console.log('Webpack HOT dev build for Rails'); // eslint-disable-line no-console

module.exports = config;
