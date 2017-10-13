# Analytics

## Creating analytics events

In javascript:

```javascript
window.ST.analytics.logEvent(category, action, opt_label, props)
```

Current events:
  * "admin", "export", "users"
  * "listing", "commented"
  * "listing", "created"
  * "message", "sent"
  * "user", "signed up", "facebook"
  * "user", "signed up", "normal form"

In controllers:

```ruby
  record_event(flash, event_category, event_data) 
```

Current events:

  * "AccountConfirmed"
  * "admin_email_confirmed"
  * "BuyButtonClicked",   {listing_id, listing_uuid, payment_process, user_logged_in}
  * "GaveConsent"
  * "InitiatePreauthorizedTransaction", {listing_id, listing_uuid}
  * "ListingViewed", {listing_id, listing_uuid, payment_process}
  * "PreauthorizedTransactionAccepted", {listing_id, listing_uuid, transaction_id}
  * "PreauthorizedTransactionRejected", {listing_id, listing_uuid, transaction_id}
  * "ProviderPaymentDetailsMissing",    {listing_id, listing_uuid}
  * "RedirectingBuyerToPayPal", { listing_id, listing_uuid, community_id, marketplace_uuid, user_logged_in}
  * "SignUp", {method}
  * "TransactionCreated", {listing_id, listing_uuid, transaction_id, payment_process}
  * "user", {action: "deleted", opt_label: "by user"})
  * "km_record", {km_event: "Onboarding cover photo uploaded"})
  * "km_record", {km_event: "Onboarding filter created"})
  * "km_record", {km_event: "Onboarding invitation created"})
  * "km_record", {km_event: "Onboarding listing created"}
  * "km_record", {km_event: "Onboarding payment disabled"})
  * "km_record", {km_event: "Onboarding payments setup"})
  * "km_record", {km_event: "Onboarding payments setup"})
  * "km_record", {km_event: "Onboarding paypal connected"})
  * "km_record", {km_event: "Onboarding slogan/description created"})

## Sending events to different engines

All analytics events are triggered as custom jQuery "st-analytics:" events.

### st-analytics:setup

Event is triggered on initialization, with user and community info, to send proper identification data to analytics engine:

```
  window.ST.analytics.data = {
      community_ident: "",
      community_uuid:  "b1b3b8e4-41e6-11e7-b73b-204747729953",
      community_id:    "1",
    
      user_id:      "eIyDCQJZ-StdbCqLMC1qEA",
      user_uuid:    "b233c084-41e6-11e7-b73b-204747729953",
      user_is_admin: true,
      user_email:    "admin@example.com",
      user_name:     "Admin D",
      user_hash:     null,
    
      feature_flags: ["topbar_v1"],
    
      plan_status:       "active",
      plan_member_limit:  null,
      plan_created_at:    1497439731,
      plan_updated_at:    1497439731,
      plan_expires_at:    null,
      plan_features:      "deletable, admin_email, whitelabel",
    
      identity_information: {
        "info_user_id_old":"eIyDCQJZ-StdbCqLMC1qEA",
        "info_marketplace_id":"b1b3b8e4-41e6-11e7-b73b-204747729953",
        "info_marketplace_id_old":1,"
        info_marketplace_url":"http://tribeme.lvh.me:3000",
        "info_email_confirmed":true
      }
    };

```

Sample handler for GTM:

```javascript
  $(document).on("st-analytics:setup", function(event, info) {
    if (info.community_id) {
      dataLayer.push({"event": "identify", "id": "mp-"+info.community_id+"-admin" });
    }

    dataLayer.push({ event: 'feature flags', featureFlags: info.feature_flags});
  });
```

### st-analytics:logout

Event is triggered on user logout, for example to clear user session if tracked.

```javascript
  $(document).on("st-analytics:logout", function(event, args){
    ampClient.setUserId(null);
    ampClient.regenerateDeviceid();
  });
```

### st-analytics:event

Triggered for new analytics event.

```javascript
window.ST.analytics.logEvent = function(category, action, opt_label, props) {
  $(document).trigger('st-analytics:event', {category: category, action: action, opt_label: opt_label, props: props});
}
```

Sample handle for Google Analytics:

```javascript
  $(document).on('st-analytics:event', function(event, args) {
    var params_array = [args.category, args.action, args.opt_label];
    if (typeof _gaq !== 'undefined' && Array.isArray(_gaq)) {
      _gaq.push(['_trackEvent'].concat(params_array));
    }
  });
```
