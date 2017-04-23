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

  function displayMoney(sum, currency, locale, opts) {
    if(typeof sum === "number" && !isNaN(sum)){
      var formatter = Intl.NumberFormat(locale, {style: "currency", currency: currency})
      var digits = formatter.resolvedOptions().minimumFractionDigits;
      var total = (digits === 0 || !opts.inCents) ? sum : sum / 100;

      return formatter.format(total);

    } else {
      return "-";
    }

    return typeof sum === "number" && !isNaN(sum) ? sum.toFixed(2) : "-";
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
