window.ST = window.ST || {};

/**
  Maganage members in admin UI
*/
window.ST.initializeManageMembers = function() {
  //$(".admin-members-can-post-listings").asEventStream("click").log("change")
  // $("#posting-allowed_dgSy4ysQWr44aaUi0sbZZU").click(function() {
  //   alert('test')
  // })

  $(".admin-members-can-post-listings").asEventStream("click").map(function() { return "you cliekd me"}).log("Now log")
}
