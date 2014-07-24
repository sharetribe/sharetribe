window.ST = window.ST || {};

(function(module) {

  module.initializeFromToDatePicker = function(rangeCongainerId) {
    var now = new Date();
    var today = new Date(now.getFullYear(), now.getMonth(), now.getDate(), 0, 0, 0, 0);
    var dateRage = $('#'+ rangeCongainerId)
    var dateLocale = dateRage.data('locale');
    var dateFormat = dateRage.data('dateformat')

    var options = {
      format: dateFormat,
      startDate: today,
      weekStart: 1,
      onRender: function(date) {
        return date.valueOf() < today.valueOf() ? 'disabled' : '';
      }
    };

    if(dateLocale !== 'en') {
      options.language = dateLocale;
    }

    dateRage.datepicker(options);
  }

})(window.ST);
