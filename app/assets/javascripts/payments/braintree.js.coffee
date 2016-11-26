# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/
paymentForm = ->
  if typeof gon != 'undefined'
    return braintree.setup(gon.client_token, 'dropin',
      container: 'braintreeDropin'
      paypal:
        singleUse: false
        currency: 'USD'
        button: type: 'checkout')
  return
$(paymentForm)

