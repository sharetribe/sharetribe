// Common webpack configuration for server bundle

const webpack = require('webpack');
const path = require('path');

const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';

module.exports = {

  // the project dir
  context: __dirname,
  entry: [
    'babel-polyfill',
    // dummy version:
    './app/startup/serverRegistration',
    //'./app/bundles/HelloWorld/startup/serverRegistration',
  ],
  output: {
    filename: 'server-bundle.js',
    path: '../app/assets/webpack',
  },
  resolve: {
    extensions: ['', '.js', '.jsx'],
    alias: {
      // dummy version originally:
      // no idea what that libs folder is.
      libs: path.join(process.cwd(), 'app', 'libs'),
      // previous generator line: lib: path.join(process.cwd(), 'app', 'lib'),
    },
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env': {
        NODE_ENV: JSON.stringify(nodeEnv),
      },
    }),
  ],
  module: {
    loaders: [
      { test: /\.jsx?$/, loader: 'babel-loader', exclude: /node_modules/ },
      {
        test: /\.css$/,
        loaders: [
          'css/locals?modules&importLoaders=0&localIdentName=[name]__[local]__[hash:base64:5]',
        ],
      },
      {
        test: /\.scss$/,
        loaders: [
          'css/locals?modules&importLoaders=2&localIdentName=[name]__[local]__[hash:base64:5]',
          'sass',
          'sass-resources',
        ],
      },
    ],
  },

  sassResources: ['./app/assets/styles/app-variables.scss'],

};