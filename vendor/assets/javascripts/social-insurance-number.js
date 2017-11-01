(function(global) {
  var SIN_LENGTH = 9;
  var TEMPORARY_RESIDENT_FIRST_DIGIT = 9;
  // Map Canadian provinces to associated first SIN digits
  var PROVINCES = {
    "AB": [6],
    "BC": [7],
    "MB": [6],
    "NB": [1],
    "NF": [1],
    "NS": [1],
    "NT": [6],
    "NU": [6],
    "ON": [4, 5],
    "PE": [1],
    "QC": [2, 3],
    "SK": [6],
    "YT": [7]
  };

  var SocialInsuranceNumber = function(sin) {
    this.sin = sin;
  };

  SocialInsuranceNumber.generate = function(options) {
    options = options || {};
    var startsWith = options.startsWith;
    if (!startsWith) {
      var province = options.province || randomChoice(Object.keys(PROVINCES));
      startsWith = randomChoice(PROVINCES[province]);
    }
    var sinArray = String(startsWith).substring(0, (SIN_LENGTH - 1)).split("");
    // Generate the next digits randomly
    while(sinArray.length < (SIN_LENGTH - 1)) {
      sinArray.push(randomIntBetween(0, 9));
    }
    sinArray.push(checkDigit(sinArray));
    return sinArray.join("");
  };

  SocialInsuranceNumber.prototype.normalizedValue = function() {
    this._normalizedValue = this._normalizedValue || String(this.sin).replace(/[^\d]/g, "");
    return this._normalizedValue;
  };

  SocialInsuranceNumber.prototype.isValid = function() {
    return luhnChecksum(this.normalizedValue()) % 10 === 0;
  };

  SocialInsuranceNumber.prototype.isTemporary = function() {
    return this.firstDigit() === TEMPORARY_RESIDENT_FIRST_DIGIT;
  };

  SocialInsuranceNumber.prototype.provinces = function() {
    var provinces = [];
    for(var province in PROVINCES) {
      if (PROVINCES[province].indexOf(this.firstDigit()) >= 0) {
        provinces.push(province);
      }
    }
    return provinces;
  };

  SocialInsuranceNumber.prototype.firstDigit = function() {
    return parseInt(this.normalizedValue().substring(0, 1), 10);
  };

  // Fast Luhn checksum code from luhn.js:
  // https://gist.github.com/ShirtlessKirk/2134376
  var luhnChecksum = function(sin) {
    var len = SIN_LENGTH,
        mul = 0,
        luhnArr = [
          [0, 1, 2, 3, 4, 5, 6, 7, 8, 9],
          [0, 2, 4, 6, 8, 1, 3, 5, 7, 9]
        ],
        sum = 0;
    while (len--) {
      sum += luhnArr[mul][parseInt(sin.charAt(len), 10)];
      mul = mul ^ 1;
    }
    return sum % 10;
  };

  // `partialSin` has first 8 digits of the SIN for which to calculate check digit.
  var checkDigit = function(partialSin) {
    var checksum = luhnChecksum(partialSin.join("") + "0");
    return checksum % 10 === 0 ? 0 : 10 - checksum;
  };

  var randomChoice = function(arr) {
    return arr[Math.floor(Math.random() * arr.length)];
  };

  var randomIntBetween = function(min, max) {
    return Math.floor(Math.random() * (max - min + 1)) + min;
  };

  SocialInsuranceNumber.PROVINCES = PROVINCES;
  SocialInsuranceNumber.SIN_LENGTH = SIN_LENGTH;

  if (typeof exports !== 'undefined') {
    if (typeof module !== 'undefined' && module.exports) {
      exports = module.exports = SocialInsuranceNumber;
    }
    exports.SocialInsuranceNumber = SocialInsuranceNumber;
  }
  else {
    global.SocialInsuranceNumber = SocialInsuranceNumber;
  }
})(this);
