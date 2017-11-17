window.ST = window.ST || {};

(function(module) {

  var dateAtBeginningOfDay = function(date) {
    return new Date(date.getFullYear(), date.getMonth(), date.getDate(), 0, 0, 0, 0);
  };

  var pad = function(num, size) {
    var s = num+"";
    while (s.length < size) s = "0" + s;
    return s;
  };

  // this ignores time zone
  var dateToString = function(date) {
    return date.getFullYear() + '-' + pad((date.getMonth() + 1), 2) + '-' +  pad(date.getDate(), 2);
  };

  var setupPerDayOrNight = function(options) {
    var disabledDates = options.blocked_dates.map(function(d) {
      return new Date(d * 1000);
    });
    var quantityNight = options.listing_quantity_selector === 'night';

    $.fn.datepicker.dates[options.locale] = options.localized_dates;

    $.validator.addMethod("night_selected",
      function(value, element, params) {
        var startVal = $(params.startOnSelector).val();
        if (!!startVal === false) {
          return true;
        } else {
          return startVal !== value;
        }
      });

    $.validator.addMethod("availability_range",
      function(value, element, params) {
        var startVal = $(params.startOnSelector).datepicker('getDates');
        var endVal = $(element).datepicker('getDates');

        if (!startVal || startVal.length !== 1 || !endVal || endVal.length !== 1) {
          return false;
        }

        var startDate = startVal[0].getTime();
        var endDate = endVal[0].getTime();

        // Validate that all booked dates are outside the selected range
        return disabledDates.every(function(d) {
          var date = d.getTime();
          if (startDate === endDate) {
            return date !== startDate;
          }
          return date < startDate || date >= endDate;
        });
      });

    var rules = quantityNight ? {
      "end_on": {
        night_selected: {startOnSelector: "#start-on"},
        availability_range: {startOnSelector: "#start-on"}
      }
    } : {
      "end_on": {
        availability_range: {startOnSelector: "#start-on"}
      }
    };

    $("#booking-dates").validate({
      rules: rules,
      submitHandler: function(form) {
        var $form = $(form);
        $form.find("#start-on").attr("name", "");
        $form.find("#end-on").attr("name", "");

        form.submit();
      }
    });

    var endDate = new Date(options.end_date * 1000);

    initializeFromToDatePicker('datepicker', {disabledDates: disabledDates, endDate: endDate, nightPicker: quantityNight });
  };

  /**
     Initialize date range picker

     params:

     - `rangeContainerId`: element id
     - `endDate`: Last date that can be selected (type: Date)
     - `disabledDates`: Array of disabled dates (type: Array of Date)
  */
  var initializeFromToDatePicker = function(rangeContainerId, opts) {
    opts = opts || {};
    var nightPicker = opts.nightPicker || false;
    var endDate = opts.endDate;
    var disabledStartDates = opts.disabledDates || [];
    var disabledEndDates = disabledStartDates.map(function(d) {
      var clonedDate = new Date(d.getTime());
      clonedDate.setDate(clonedDate.getDate() + 1);
      return clonedDate;
    });
    var today = dateAtBeginningOfDay(new Date());
    var dateRage = $('#'+ rangeContainerId);
    var dateLocale = dateRage.data('locale');

    var options = {
      startDate: today,
      inputs: [$("#start-on"), $("#end-on")],
      endDate: endDate,
      datesDisabled: disabledStartDates,
      plusOne: nightPicker
    };

    if(dateLocale !== 'en') {
      options.language = dateLocale;
    }

    var picker = dateRage.datepicker(options);

    if (nightPicker) {
      $("#start-on").focus(function() {
        if(!$(this).is(":focus")) {
          $("#start-on").datepicker("setDatesDisabled", disabledStartDates);
        }
      });

      $("#end-on").focus(function() {
        if(!$(this).is(":focus")) {
          $("#end-on").datepicker("setDatesDisabled", disabledEndDates);
        }
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

      if (outputElementId === "booking-end-output" && !nightPicker) {
        // Add one day to end date if the picker is day picker
        // End date should be excluded
        newDate.setDate(newDate.getDate() + 1);
      }
      outputElement.val(module.utils.toISODate(newDate));
      setTimeout(function() { $("#end-on").valid(); }, 360);
    });

  };

  var setupPerHour = function(options) {
    var dateInput = $('#start-on');
    var disabledDates = options.blocked_dates.map(function(d) {
      return new Date(d * 1000);
    });
    var today = dateAtBeginningOfDay(new Date());
    var endDate = new Date(options.end_date * 1000);

    $.fn.datepicker.dates[options.locale] = options.localized_dates;

    var picker = dateInput.datepicker({
      autoclose: true,
      datesDisabled: disabledDates,
      startDate: today,
      endDate: endDate,
      language: options.locale
    });

    var validateForm = function() {
      $('#booking-dates').validate();
    };

    var setUpSelectOptions = function(date_options) {
      var options_for_select = ['<option value="" disabled selected>Select one</option>'];
      for(var index in date_options) {
        var option = date_options[index];
        var disabled = option.disabled ? ' disabled ' : '';
        options_for_select.push('<option value="' + option.value + '" ' + disabled + '>' + option.name + '</option>');
      }
      $('#start_time').html($(options_for_select.join('')));
      $('#end_time').html($(options_for_select.join('')));
    };

    picker.on('changeDate', function(e) {
      var date = dateToString(e.date);
      console.log('change to ' + date);
      setUpSelectOptions(options.options_for_select[date]);
    });
    validateForm();
  };

  module.FromToDatePicker = {
    setupPerDayOrNight: setupPerDayOrNight,
    setupPerHour: setupPerHour
  };
})(window.ST);
