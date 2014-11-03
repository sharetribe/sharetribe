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

  function displayMoney(sum) {
    return typeof sum === "number" && !isNaN(sum) ? sum.toFixed(2) : "-";
  }

  function totalCommission(totalSum, communityCommissionPercentage, minCommission) {
    minCommission = minCommission || 0;
    var commission = totalSum * communityCommissionPercentage / 100;
    return Math.max(commission, minCommission);
  }

  return {
    parseFloatFromFieldValue: parseFloatFromFieldValue,
    displayMoney: displayMoney,
    totalCommission: totalCommission
  };
})();
