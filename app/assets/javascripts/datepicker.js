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
        var oneDayMore = new Date(newDate);
        oneDayMore.setDate(oneDayMore.getDate() + 1);
        if (oneDayMore <= endDate) {
          newDate = oneDayMore;
        }
      }

      if (outputElementId === "booking-start-output") {
        $("#start-on").datepicker('hide')
        $("#end-on").focus().datepicker('show')
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
    var currentDate = null;
    var selectOne = ST.t('listings.listing_actions.select_one');

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

    $('#start_time').on('change', function() {
      var selected = $(this).find('option:selected'),
        startTimeindex = selected.data('index'),
        startTimeSlot = selected.data('slot'),
        endTime = $('#end_time'),
        prevBlocked = false;
      if (endTime.prop('disabled') != true) {
        setUpSelectOptions(currentDate, false, '#end_time');
      }
      endTime.find('option').each(function () {
        var option = $(this), endTimeIndex = option.data('index'),
          endTimeSlot = option.data('slot'), blocked  = option.data('blocked'),
          bookingStart = option.data('bookingStart');
        if (endTimeIndex > startTimeindex && startTimeSlot === endTimeSlot &&
          (!blocked || (!prevBlocked && bookingStart))) {
          option.removeAttr('disabled');
        } else {
          option.prop('disabled', true);
        }
        prevBlocked = blocked;
      });
      endTime.removeAttr('disabled');
    });

    var setUpSelectOptions = function(date, start, selectSelector) {
      var date_options = options.options_for_select[date],
        options_for_select = ['<option value="" disabled selected>' + selectOne + '</option>'],
        prevDisabled = false,
        blocked = '';
      for(var index in date_options) {
        var disabled, option = date_options[index],
          value = date + ' ' + option.value;
        if (!start && option.slot_end && !prevDisabled) {
          disabled = '';
          blocked = '';
          if (option.next_day) {
            value = option.next_day + ' ' + option.value;
          }
        } else {
          disabled = option.disabled ? ' disabled ' : '';
          blocked = option.disabled ? 'true' : '';
        }
        if (!(start && option.slot_end)) {
          options_for_select.push('<option value="' + value + '" ' + disabled +
            ' data-index="' + index + '" data-slot="' + option.slot +
            '" data-blocked="' + blocked + '" data-booking-start="' + !!option.booking_start + '" >' + option.name + '</option>');
        }
        prevDisabled = option.disabled;
      }
      $(selectSelector).html($(options_for_select.join('')));
      if (!start) {
        $(selectSelector).prop('disabled', true);
      }
    };

    picker.on('changeDate', function(e) {
      currentDate = dateToString(e.date);
      setUpSelectOptions(currentDate, true, '#start_time');
      setUpSelectOptions(currentDate, false, '#end_time');
    });
    validateForm();
  };

  module.FromToDatePicker = {
    setupPerDayOrNight: setupPerDayOrNight,
    setupPerHour: setupPerHour
  };
})(window.ST);
