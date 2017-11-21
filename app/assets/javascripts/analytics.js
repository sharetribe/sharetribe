window.ST = window.ST || {};

window.ST.analytics = (function(){
  var init = function(options) {
    $(document).ready(function() {
      $(document).trigger('st-analytics:setup', options.analyticsData);
      if (options.events) {
        for(var i = 0; i < options.events.length; i++) {
          var _event = options.events[i];
          logEvent( _event.event, _event.action, null, _event.props);
        }
      }
      if (options.logout) {
        logout();
      }
    });
  };

  var logEvent = function(category, action, opt_label, props) {
    $(document).trigger('st-analytics:event', {category: category, action: action, opt_label: opt_label, props: props});
  };

  var logout = function() {
    $(document).trigger('st-analytics:logout');
  };

  var initAmplitude = function(amplitudeApiKey) {
    var ampClient;
    if (window.amplitude) {
      ampClient = amplitude.getInstance();
      ampClient.init(amplitudeApiKey);
    } else {
      return;
    }
    $(document).on("st-analytics:setup", function(event, info) {
      var userInfo = new amplitude.Identify()
                                  .set('community_id', info.community_id)
                                  .set('marketplace_uuid', info.community_uuid)
                                  .set('admin', info.user_is_admin);

      if (info.plan_status) {
        userInfo.set('plan_status', info.plan_status);
      }

      if (info.user_uuid) {
        ampClient.setUserId(info.user_uuid);
      }

      ampClient.identify(userInfo);
    });

    $(document).on("st-analytics:event", function(event, args){
      ampClient.logEvent(args.category, args.props);
    });

    $(document).on("st-analytics:logout", function(event, args){
      ampClient.setUserId(null);
      ampClient.regenerateDeviceid();
    });
  };

  var initKissmetrics = function(kmq) {
    $(document).on("st-analytics:setup", function(event, info) {
      if(info.user_id) {
        kmq.push(['identify', info.user_id]);
      }
      if(info.community_ident) {
        kmq.push(['set', {'SiteName' : info.community_ident}]);
      } else {
        kmq.push(['set', {'SiteName' : 'dashboard'}]);
      }
    });
  };

  var initGoogleAnalytic = function() {
    $(document).on('st-analytics:event', function(event, args) {
      ST.customerReportEvent(args.category, args.action, args.opt_label);
    });
  };

  var initLegacyGoogleAnalytic = function(gaq) {
    $(document).on('st-analytics:event', function(event, args) {
      var params_array = [args.category, args.action, args.opt_label];
      if (typeof gaq !== 'undefined' && Array.isArray(_gaq)) {
        gaq.push(['_trackEvent'].concat(params_array));
      }
    });
  };

  var initGoogleTagManager= function(gtm_identify) {
    $(document).on('st-analytics:event', function(event, args) {
      if (args.category == 'km_record') {
        var data = $.extend({}, args.props);
        data.event = 'km_record';
        window.ST.gtmPush(data);
      } else {
        window.ST.gtmPush({
          'event' : 'GAEvent',
          'eventCategory' : args.category,
          'eventAction' : args.saction,
          'eventLabel' : args.opt_label,
          'eventValue' : undefined
        });
      }
    });

    $(document).on('st-analytics:setup', function(event, info) {
      _gtm_identify(dataLayer, info);
    });
  };

  var initIntercom = function(APP_ID) {
    $(document).on("st-analytics:setup", function(event, info) {
      window.intercomSettings = Object.assign({
        // Identifier
        user_id: info.user_uuid,
        user_hash: info.user_hash,
        // Standard Intercom fields
        app_id: APP_ID,
        email: info.user_email,
        name: info.user_name,
        // Custom attributes ('info_' prefix)
        info_plan_status: info.plan_status,
        info_plan_features: info.plan_features,
        info_plan_member_limit: info.plan_member_limit,
        info_plan_created_at: info.plan_created_at,
        info_plan_updated_at: info.plan_updated_at,
        info_plan_expires_at: info.plan_expires_at,
        info_feature_flags: info.feature_flags,
        info_trial_creation_status: "complete"
      }, info.identity_information);
      /*jshint ignore:start*/
      (function(){var w=window;var ic=w.Intercom;if(typeof ic==="function"){ic('reattach_activator');ic('update',intercomSettings);}else{var d=document;var i=function(){i.c(arguments)};i.q=[];i.c=function(args){i.q.push(args)};w.Intercom=i;function l(){var s=d.createElement('script');s.type='text/javascript';s.async=true;s.src='https://widget.intercom.io/widget/' + APP_ID;var x=d.getElementsByTagName('script')[0];x.parentNode.insertBefore(s,x);}if(w.attachEvent){w.attachEvent('onload',l);}else{w.addEventListener('load',l,false);}}})();
      /*jshint ignore:end*/

    });

    $(document).on("st-analytics:event", function(event, args) {
      window.Intercom('trackEvent', args.category, args.props ? args.props : args);
    });
  };


  return {
    "init": init,
    "logEvent": logEvent,
    "logout": logout,
    "initAmplitude": initAmplitude,
    "initKissmetrics": initKissmetrics,
    "initGoogleAnalytic": initGoogleAnalytic,
    "initLegacyGoogleAnalytic": initLegacyGoogleAnalytic,
    "initGoogleTagManager": initGoogleTagManager,
    "initIntercom": initIntercom
  };
})();
