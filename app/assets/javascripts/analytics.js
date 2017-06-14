window.ST = window.ST || {};

window.ST.analytics = window.ST.analytics || {};

window.ST.analytics.setup = function(user_and_community_info) {
  $(document).trigger('st-analytics:setup', user_and_community_info);
}

window.ST.analytics.logEvent = function(category, action, opt_label, props) {
  $(document).trigger('st-analytics:event', {category: category, action: action, opt_label: opt_label, props: props});
}

window.ST.analytics.logout = function() {
  $(document).trigger('st-analytics:logout');
}
