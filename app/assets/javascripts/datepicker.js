window.ST = window.ST || {};

(function(module) {

  /**
     Initialize date range picker

     params:

     - `rangeContainerId`: element id
     - `endDate`: Last date that can be selected (type: Date)
     - `disabledDates`: Array of disabled dates (type: Array of Date)
  */
  module.initializeFromToDatePicker = function(rangeContainerId, opts) {
    opts = opts || {};
    var nightPicker = opts.nightPicker || false;
    var endDate = opts.endDate;
    var disabledStartDates = opts.disabledDates || [];
    var disabledEndDates = disabledStartDates.map(function(d) {
      var clonedDate = new Date(d.getTime());
      clonedDate.setDate(clonedDate.getDate() + 1);
      return clonedDate;
    });
    var now = new Date();
    var today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    var dateRage = $('#'+ rangeContainerId);
    var dateLocale = dateRage.data('locale');

    var options = {
      startDate: today,
      inputs: [$("#start-on"), $("#end-on")],
      endDate: endDate,
      datesDisabled: disabledStartDates
    };

    if(dateLocale !== 'en') {
      options.language = dateLocale;
    }

    var picker = dateRage.datepicker(options);

    if (nightPicker) {
      $("#start-on").focus(function() {
        $("#start-on").datepicker("setDatesDisabled", disabledStartDates);
      });

      $("#end-on").focus(function() {
        $("#end-on").datepicker("setDatesDisabled", disabledEndDates);
      });
    }

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
