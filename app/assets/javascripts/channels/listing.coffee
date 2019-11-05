App.cable.subscriptions.create('ListingsChannel', {
  connected: ->
    console.log("Viva!")
    @follow()

  follow: ->
    @perform 'follow'

  received: (data) ->
    $(".price_aucsion").replaceWith data
})
