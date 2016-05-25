const replacePercentChar = function replacePercentChar(uriString) {
  // webpack loaderUtils didn't understand '%' char
  if (uriString.indexOf('%d') >= 0) {
    return uriString.replace('%d', '__d__');
  }
  return uriString;
};
module.exports = { replacePercentChar }; // eslint-disable-line no-undef
