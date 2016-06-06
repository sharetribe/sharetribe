/* eslint-env node */

const webpack = require('webpack');
const ExtractTextPlugin = require('extract-text-webpack-plugin');
const config = require('./webpack.client.base.config');
const devBuild = process.env.NODE_ENV !== 'production';

config.output = {
  filename: '[name]-bundle.js',
  path: '../app/assets/webpack',
  publicPath: '/assets/',
};

config.module.loaders.push(
  {
    test: /\.js$/,
    loader: 'babel-loader',
    exclude: [/node_modules/, /routes\/routes.js/],
  },
  {
    test: /\.css$/,
    loader: ExtractTextPlugin.extract(
      'style-loader',
      'css-loader?modules&localIdentName=[name]__[local]__[hash:base64:5]' + // eslint-disable-line prefer-template
        (devBuild ? '' : '&minimize') +
        '!postcss-loader'
    ),
  },
  {
    test: require.resolve('react'),
    loader: 'imports?shim=es5-shim/es5-shim&sham=es5-shim/es5-sham',
  }
);

config.plugins.push(
  new ExtractTextPlugin('[name]-bundle.css', { allChunks: true }),
  new webpack.optimize.DedupePlugin()
);

if (devBuild) {
  console.log('Webpack dev build for Rails'); // eslint-disable-line no-console
  config.devtool = 'eval-source-map';
} else {
  console.log('Webpack production build for Rails'); // eslint-disable-line no-console
}

module.exports = config;
