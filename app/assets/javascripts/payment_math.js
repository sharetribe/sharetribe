// Namespace
window.ST = window.ST || {};

window.ST.paymentMath = (function() {

  /**
    Parses a numeric field value and returns correct float value,
    whether dot or comma is used as a decimal separator.

    Not really a payment math function, but needed to parse the sum
  */
  function parseFloatFromFieldValue(value) {
    return parseFloat(value.replace(',', '.'));
  }

  function parseSubunitFloatFromFieldValue(value, subunit_to_unit) {
    return parseFloatFromFieldValue(value) * subunit_to_unit;
  }

  function localizeNumber(number, digits, separator, delimiter) {
    return number
      .toFixed(digits)
      .replace(".", separator)
      .replace(/(\d)(?=(\d{3})+(?!\d))/g, "$1" + delimiter);
  }

  function localizeCurrency(number, unit, format) {
    return format
      .replace("%u", unit)
      .replace("%n", number);
  }

  /* Displays a sum of money, localized with the parameters.
     @param {number} sum - sum of money in cents
     @param {string} symbol
     @param {number} digits - amount of fractional units in currency
     @param {string} format - localization format for money,
                              e.g. %u%n, where:
                              %u is unit (symbol)
                              %n is number (sum)
     @param {string} separator - decimal separator
     @param {string} delimiter - thousand delimiter
     @return {string} Localized sum of money, e.g. "$1,000.23"
  */
  function displayMoney(sum, symbol, digits, format, separator, delimiter) {
    if(typeof sum === "number" && !isNaN(sum)){
      var value = sum / Math.pow(10, digits);
      var localizedNumber = localizeNumber(value, digits, separator, delimiter);
      return localizeCurrency(localizedNumber,
                              symbol,
                              format);
    } else {
      return "-";
    }
  }

  function totalCommission(totalSum, communityCommissionPercentage, minCommission) {
    minCommission = minCommission || 0;
    var commission = totalSum * communityCommissionPercentage / 100;
    return Math.max(commission, minCommission);
  }

  return {
    parseFloatFromFieldValue: parseFloatFromFieldValue,
    parseSubunitFloatFromFieldValue: parseSubunitFloatFromFieldValue,
    displayMoney: displayMoney,
    totalCommission: totalCommission
  };
})();
