/* eslint-disable */
var Promise = require('bluebird');
var fse = Promise.promisifyAll(require('fs-extra'));
var loaderUtils = require('loader-utils');
var mime = require('mime');
var path = require('path');

module.exports = function (content) {
  if (typeof this.cacheable === 'function') {
    this.cacheable();
  }

  if (!this.emitFile) {
    throw new Error('emitFile is required from module system');
  }

  var query = loaderUtils.parseQuery(this.query);
  var url = loaderUtils.interpolateName(this, query.name || '[hash].[ext]', {
    context: query.context || this.options.context,
    content: content,
    regExp: query.regExp
  });

  var resolveAssetHost = function resolveAssetHost(assetHost) {
    // asset_host can point to several asset servers at CDN
    // they are numbered from 0 to 3
    if (assetHost.indexOf('__d__') >= 0) {
      var random0to3 = Math.floor(Math.random() * 4);
      return assetHost.replace('__d__', random0to3);
    }
    return assetHost;
  };

  // url-loader functionality
  var limit = (this.options && this.options.url && this.options.url.dataUrlLimit) || 0;
  var mimetype = query.mimetype || mime.lookup(this.resourcePath);
  if (query.limit) {
    limit = parseInt(query.limit, 10);
  }

  if (limit <= 0 || content.length < limit) {
    return 'module.exports = ' + JSON.stringify('data:' + (mimetype ? mimetype + ';' : '') + 'base64,' + content.toString('base64'));
  }

  // Copy asset to production folder
  var assetFromPath = this.resourcePath;
  var assetToPath = path.resolve(
    process.cwd(),
    '..',
    'public/webpack/',
    url
  );

  fse.exists(assetToPath, function (exists) {
    if (!exists) {
      fse.copy(assetFromPath, assetToPath, function (err) {
        if (err) {
          return console.error(err);
        }
        console.log('Asset ["' + path.basename(assetFromPath) + '"] is copied to ' + assetToPath);
      });
    }
  });

  if (query.asset_host) {
    return 'module.exports = ' + JSON.stringify('//' + resolveAssetHost(query.asset_host) + '/webpack/' + url) + ';';
  } else if(query.hotMode){
    // Emit file if images are big and Rails is not responsible for serving assets.
    this.emitFile(url, content);
    // publicPath is set in webpack config files. With Rails, assets are served from /assets/
    return 'module.exports = __webpack_public_path__ + ' + JSON.stringify(url) + ';';
  }

  // publicPath is set in webpack config files. With Rails, assets are served from /assets/
  return 'module.exports =  ' + JSON.stringify('/webpack/' + url) + ';';
};

module.exports.raw = true;
