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

  function serviceFee(sum, commissionPercentage) {
    return Math.ceil(sum * commissionPercentage / 100);
  }

  /**
    round(100/3*2, 2) -> 66.67
  */
  function round(num, decimals) {
    decimals = decimals || 0;
    var factor = Math.pow(10, decimals);

    return Math.round(num * factor) / factor;
  }

  function displayMoney(sum) {
    return typeof sum === "number" && !isNaN(sum) ? sum.toFixed(2) : "-";
  }

  return {
    parseFloatFromFieldValue: parseFloatFromFieldValue,
    serviceFee: serviceFee,
    displayMoney: displayMoney,
    round: round
  };
})();
