  // =======================================================================
// PageLess - endless page
//
// Author: Jean-Sébastien Ney (jeansebastien.ney@gmail.com)
// Contributors:
//	Alexander Lang (langalex)
// 	Lukas Rieder (Overbryd)
//
// Parameters:
//    currentPage: current page (params[:page])
//    distance: distance to the end of page in px when ajax query is fired
//    loader: selector of the loader div (ajax activity indicator)
//    loaderHtml: html code of the div if loader not used
//    loaderImage: image inside the loader
//    loaderMsg: displayed ajax message
//    pagination: selector of the paginator divs. (if javascript is disabled paginator is required)
//    params: paramaters for the ajax query, you can pass auth_token here
//    totalPages: total number of pages
//    url: URL used to request more data
//    div1: first div to append to if returned data contains two parts divided by splilt_string
//    div2: second div to append to if returned data contains two parts divided by splilt_string
//    split_string: a string to divide two parts of content in data
// Callback Parameters:
//		scrape: A function to modify the incoming data. (Doesn't do anything by default)
//		complete: A function to call when a new page has been loaded (optional)
//		afterStopListener: A function to call when the last page has been loaded (optional)
//
// Requires: jquery + jquery dimensions
//
// Thanks to:
//  * codemonky.com/post/34940898
//  * www.unspace.ca/discover/pageless/
//  * famspam.com/facebox
// =======================================================================
 
(function($) {
  $.pageless = function(settings) {
    $.isFunction(settings) ? settings.call() : $.pageless.init(settings);
  };
  
  // available params
  //loader: loading div
  // pagination: div selector for the pagination links
  // loaderMsg:
  // loaderImage:
  // loaderHtml:
  $.pageless.settings = {
    currentPage:  1,
    pagination:   '.pagination',
    url:          location.href,
    params:       {}, // params of the query you can pass auth_token here
    distance:     600, // page distance in px to the end when the ajax function is launch
    loaderImage:  "/images/load.gif",

		scrape: function(data) { 
		  if (typeof($.pageless.div2) != 'undefined') { // means that we have 2 div update
  		  arr = data.split($.pageless.settings.split_string);
  		  return arr;
		  } else {
		    return data;
		  }
		} 
  };
  
  $.pageless.loaderHtml = function(){
    return $.pageless.settings.loaderHtml || '\
<div id="pageless-loader" class="grid_9" style="display:none;text-align:center;width:100%;">\
  <div class="msg" style="color:#bbbbbb;font-size:2em"></div>\
  <img src="' + $.pageless.settings.loaderImage + '" title="load" alt="loading more results" style="margin: 10px auto" />\
</div>';
  };
 
  // settings params: totalPages
  $.pageless.init = function(settings) {
    if ($.pageless.settings.inited) return;
    $.pageless.settings.inited = true;
    
    if (settings) $.extend($.pageless.settings, settings);
    
    // for accessibility we can keep pagination links
    // but since we have javascript enabled we remove pagination links 
    if($.pageless.settings.pagination)
      $($.pageless.settings.pagination).remove();

    // start the listener
    $.pageless.startListener();
  };
  
  // init loader val
  $.pageless.isLoading = false;
  
  $.fn.pageless = function(settings) {
    $.pageless.init(settings);
    
    // Detect if url has changed, and reset the settings and listener
    // If settings are changed by ajax, the old values seems to persist unless explicitly changed 
    if ($.pageless.settings.url != settings["url"]) {
      $.pageless.stopListener();
      $.pageless.settings.url = settings["url"];
      $.pageless.settings.currentPage = 1;
      $.pageless.settings.totalPages = settings["totalPages"];
      $.pageless.startListener();
    }
    
    $.pageless.el = $(this);
    $.pageless.div1 = $(this).find(settings.div1)
    
    if (settings.div1 && settings.div2 && settings.split_string ) {
      $.pageless.div1 = $(this).find(settings.div1)
      $.pageless.div2 = $(this).find(settings.div2)
    }
    
    // loader element
    if(settings.loader && $(this).find(settings.loader).length){
      $.pageless.loader = $(this).find(settings.loader);
    } else {
      $.pageless.loader = $($.pageless.loaderHtml());
      $(this).append($.pageless.loader);
      // if we use the default loader, set the message
      if(!settings.loaderHtml) { $('#pageless-loader .msg').html(settings.loaderMsg) }
    }
  };
  
  //
  $.pageless.loading = function(bool){
    if(bool === true){
      $.pageless.isLoading = true;
      if($.pageless.loader)
        $.pageless.loader.fadeIn('normal');
    } else {
      $.pageless.isLoading = false;
      if($.pageless.loader)
        $.pageless.loader.fadeOut('normal');
    }
  };
  
  $.pageless.stopListener = function() {
    $(window).unbind('.pageless');
  };
  
  $.pageless.startListener = function() {
    $(window).bind('scroll.pageless', $.pageless.scroll);
  };
  
  $.pageless.scroll = function() {
    // listener was stopped or we've run out of pages
    if($.pageless.settings.totalPages <= $.pageless.settings.currentPage){
      $.pageless.stopListener();
			// if there is a afterStopListener callback we call it
      if ($.pageless.settings.afterStopListener) { $.pageless.settings.afterStopListener.call(); }
      return;
    }
    
    // distance to end of page
    var distance = $(document).height()-$(window).scrollTop()-$(window).height();
    // if slider past our scroll offset, then fire a request for more data
    if(!$.pageless.isLoading && (distance < $.pageless.settings.distance)) {
      $.pageless.loading(true);
      // move to next page
      $.pageless.settings.currentPage++;
      // set up ajax query params
      $.extend($.pageless.settings.params, {page: $.pageless.settings.currentPage});
      // finally ajax query
      $.get($.pageless.settings.url, $.pageless.settings.params, function(data){
				var data = $.pageless.settings.scrape(data);
			  if (typeof($.pageless.div2) !== 'undefined') { // means that we have 2 div update
				  $.pageless.div1.append(data[0]);
				  $.pageless.div2.append(data[1]);
			  } else {
			    //$.pageless.div1.append(data);
			    if ($.pageless.loader) { $.pageless.loader.before(data) } else { $.pageless.el.append(data) }
			  }

        
        $.pageless.loading(false);
        // if there is a complete callback we call it
        if ($.pageless.settings.complete) { $.pageless.settings.complete.call(); }
      });
    }
  };
})(jQuery);