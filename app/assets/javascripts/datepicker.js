window.ST = window.ST || {};

(function(module) {

  module.initializeFromToDatePicker = function(rangeCongainerId) {
    var now = new Date();
    var today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    var dateRage = $('#'+ rangeCongainerId);
    var dateLocale = dateRage.data('locale');

    var options = {
      startDate: today,
      inputs: [$("#start-on"), $("#end-on")],
      onRender: function(date) {
        return date.valueOf() < today.valueOf() ? 'disabled' : '';
      }
    };

    if(dateLocale !== 'en') {
      options.language = dateLocale;
    }

    var picker = dateRage.datepicker(options);

    var outputElements = {
      "booking-start-output": $("#booking-start-output"),
      "booking-end-output": $("#booking-end-output")
    };

    picker.on('changeDate', function(e) {
      var newDate = e.dates[0];
      var outputElementId = $(e.target).data("output");
      var outputElement = outputElements[outputElementId];
      outputElement.val(module.utils.toISODate(newDate));
    });
  };
})(window.ST);
