/* eslint-env node */

const webpack = require('webpack');
const devBuild = process.env.NODE_ENV !== 'production';
const nodeEnv = devBuild ? 'development' : 'production';

const { replacePercentChar } = require('./webpackConfigUtil');
const assetHostEnv = typeof process.env.asset_host === 'string' ? `&asset_host=${process.env.asset_host}` : '';
const assetHost = replacePercentChar(assetHostEnv);
const TerserPlugin = require('terser-webpack-plugin');
const MiniCssExtractPlugin = require('mini-css-extract-plugin');

module.exports = {
  context: __dirname,
  entry: [
    '@babel/polyfill',
    './app/startup/serverRegistration',
  ],
  output: {
    filename: 'server-bundle.js',
    path: `${__dirname}/../app/assets/webpack`,
    publicPath: '/assets/',
  },
  resolve: {
    extensions: ['*', '.js'],
  },
  plugins: [
    new webpack.DefinePlugin({
      'process.env.NODE_ENV': JSON.stringify(nodeEnv),
    }),
    new MiniCssExtractPlugin({
      filename: 'server-bundle.css',
    }),
  ],
  module: {
    rules: [
      {
        test: /\.js$/,
        loader: 'babel-loader',
        exclude: [/node_modules/, /i18n\/all.js/],
      },
      {
        test: /\.css$/,
        rules: [
          {
            loader: MiniCssExtractPlugin.loader,
          },
          {
            loader: 'css-loader',
            options: {
              modules: {
                mode: 'local',
                localIdentName: '[name]__[local]__[hash:base64:5]',
              },
              importLoaders: 0,
            },
          },
          {
            loader: 'postcss-loader',
          },
        ],
      },
      {
        test: /\.scss$/,
        use: ['style-loader', 'css-loader', 'sass-loader'],
      },
      {
        test: /\.(jpe?g|png|gif|ico)$/,
        loader: 'file-loader',
        options: {
          limit: 10000,
          name: `[name]-[hash].[ext]${assetHost}`,
        },
      },
      {
        test: /\.svg$/,
        loader: 'raw-loader',
      },
    ],
  },
  optimization: {
    minimize: true,
    minimizer: [
      new TerserPlugin(),
    ],
  },
};
