const postcss = require('postcss');
const path = require('path');

// opts example: {helper : 'image-path', assetPath: '/app/assets/images/'})
// TODO expand helper to check all Rails asset helpers.
module.exports = postcss.plugin('postcss-image-path', function (opts) {
  opts = opts || {};
  const imagePathHelper = opts.helper || 'image-path';
  const assetPath = opts.assetPath || process.cwd();

  return function (css, result) {
    css.walkDecls(function (decl) {
      // Return if css declaration value part doesn't contain Rails helper
      // e.g. image-path('image.png')
      if (!decl.value || decl.value.indexOf( imagePathHelper + '(') === -1) {
        return;
      }

      // locate css file where Rails asset helper is found
      var filePath = process.cwd();
      if ( decl.source && decl.source.input && decl.source.input.file ) {
        filePath = decl.source.input.file;
      }

      // Figure out relative path to assets within webpack
      // Images should be found from ./client/app/assets/images/
      const relativePath = path.relative(
        path.dirname(filePath),
        process.cwd() + assetPath
      );

      // replace: background-image: url(image-path("img.png"))
      // => background-image: url("../../assets/images/img.png")
      const re = /(image-path\(["'](.*?)["']\))/g
      decl.value = decl.value.replace(re, `"${relativePath}/$2"`);
    });
  };
});
