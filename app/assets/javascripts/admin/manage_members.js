window.ST = window.ST || {};

/**
  Maganage members in admin UI
*/
window.ST.initializeManageMembers = function() {
  //$(".admin-members-can-post-listings").asEventStream("click").log("change")
  // $("#posting-allowed_dgSy4ysQWr44aaUi0sbZZU").click(function() {
  //   alert('test')
  // })
  
  function elementToValueObject(element) {
    var r = {};
    r[$(element).val()] = !! $(element).attr("checked");
    return r;
  }
  
  var streams = $(".admin-members-can-post-listings").toArray().map(function(domElement) { 
    return $(domElement).asEventStream("change").map(function(event){
      return elementToValueObject(event.target);

    }).toProperty(elementToValueObject(domElement))
  })


  Bacon.combineAsArray(streams).changes().debounce(800).map(function(valuesArray) {
    
  });
}
